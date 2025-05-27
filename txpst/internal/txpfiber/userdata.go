package txpfiber

import (
	"os"
	"path"
	"time"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
)

func placeUserData(c *fiber.Ctx, targetDir string) error {
	b := c.Body()
	if len(b) == 0 {
		log.Debug("No user data")
		return nil
	}
	f, createErr := os.Create(path.Join(targetDir, "data.json"))
	if createErr != nil {
		log.Error("failed to create file", "err", createErr.Error())
		return createErr
	}
	_, writeErr := f.Write(b)
	if writeErr != nil {
		log.Error("failed to write file", "err", writeErr.Error())
		return writeErr
	} else {
		time.Sleep(time.Millisecond * 10)
	}
	return nil
}
