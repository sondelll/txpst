package txputil

import (
	"encoding/json"
	"os"
	"os/exec"
	"path"
	"time"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
)

func PlaceUserData(c *fiber.Ctx, workDir string) error {
	b := c.Body()
	if len(b) == 0 {
		log.Debug("No user data")
		return nil
	}
	f, createErr := os.Create(path.Join(workDir, TXP_DATA_FILEPATH))
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

func PlaceContext(c *fiber.Ctx, workDir string) error {
	cmd := exec.Command("cp", "/app/template.typ", path.Join(workDir, "template.typ"))
	cmd.Run()

	cmdSvg := exec.Command("cp", "/app/ostp_black.svg", path.Join(workDir, "ostp_black.svg"))
	cmdSvg.Run()

	ctx := map[string]any{
		"fromIP":    c.IP(),
		"timestamp": time.Now().Format("2006-01-02 15:04:05 UTC"),
	}
	b, jsonErr := json.Marshal(ctx)
	if jsonErr != nil {
		return jsonErr
	}

	f, createErr := os.Create(path.Join(workDir, TXP_CONTEXT_FILEPATH))
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

func ClearAll(workDir string) {
	os.RemoveAll(workDir)
}
