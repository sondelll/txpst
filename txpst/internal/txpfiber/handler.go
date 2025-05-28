package txpfiber

import (
	"path"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
	"github.com/sondelll/txstp/txpst/internal/fs"
)

func HandleCompile(c *fiber.Ctx) error {
	reqFormat := c.Query("format", "pdf")
	if reqFormat != "pdf" && reqFormat != "png" {
		c.SendStatus(fiber.ErrNotImplemented.Code)
	}
	tName := c.Params("templateName", "")
	if tName == "" {
		return c.SendStatus(400)
	}
	wd, prepErr := prepCompile(tName)
	if prepErr != nil {
		fs.UnbotheredDelete(wd)
		return c.SendStatus(500)
	}
	if err := populate(c, wd); err != nil {
		log.Error("Failed to populate for request.", "err", err)
		return c.SendStatus(500)
	}
	b, err := compileWithDir(wd, reqFormat)

	if err != nil {
		log.Error("Failed on compile", "err", err)
		return c.SendStatus(500)
	}

	SendPdf(c, b)

	return nil
}

func prepCompile(templateName string) (string, error) {
	wd := NewWorkdir()
	err := fs.CopyAll(path.Join("/typ", templateName), path.Join("./", wd))
	if err != nil {
		log.Error("Failed to copy files", "err", err)
		return "", err
	}
	return wd, nil
}

func populate(c *fiber.Ctx, targetDir string) error {
	if err := placeUserData(c, targetDir); err != nil {
		return err
	}

	return placeContext(c, targetDir)
}
