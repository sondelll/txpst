package txpfiber

import (
	"os"
	"path"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
	"github.com/sondelll/txstp/txpst/internal/txp"
)

func compileWithDir(dirName string) ([]byte, error) {
	mainFileName := path.Join(dirName, "main.typ")
	typFileContent, tfcErr := os.ReadFile(mainFileName)
	if tfcErr != nil {
		return nil, tfcErr
	}
	tx, txErr := txp.New()
	if txErr != nil {
		return nil, txErr
	}
	result, cErr := tx.Compile(typFileContent, dirName, "pdf")
	if cErr != nil {
		return nil, cErr
	}
	return result, nil
}

func SendPdf(c *fiber.Ctx, b []byte) error {
	_, writeErr := c.Write(b)
	if writeErr != nil {
		log.Error("failed to write response", "err", writeErr.Error())
		return c.SendStatus(500)
	}

	c.Response().Header.SetContentType("application/pdf")

	return c.SendStatus(200)
}
