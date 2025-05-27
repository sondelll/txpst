package txpfiber

import (
	"encoding/json"
	"os"
	"path"
	"time"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
)

func placeContext(c *fiber.Ctx, targetDir string) error {
	ctx := map[string]any{
		"fromIP":    c.IP(),
		"timestamp": time.Now().Format("2006-01-02 15:04:05 UTC"),
	}
	b, jsonErr := json.Marshal(ctx)
	if jsonErr != nil {
		return jsonErr
	}

	f, createErr := os.Create(path.Join(targetDir, "context.json"))
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
