package main

import (
	"os"
	"os/exec"
	"time"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New(fiber.Config{DisableStartupMessage: true})
	app.Post("/", run)

	app.Listen(":8787")
}

func run(c *fiber.Ctx) error {
	auth := c.Get("Authorization")
	if auth != "1f7f1a" {
		return c.SendStatus(403)
	}
	b := c.Body()
	os.Remove("/app/data.json")
	f, err := os.Create("/app/data.json")
	if err != nil {
		log.Error("failed to create file", "err", err.Error())
		return c.SendStatus(500)
	}
	_, writeErr := f.Write(b)
	if writeErr != nil {
		log.Error("failed to write file", "err", writeErr.Error())
		return c.SendStatus(500)
	} else {
		time.Sleep(time.Millisecond * 25)
	}

	cmd := exec.Command("typst", "compile", "--font-path", "/usr/fonts", "/app/doc.typ", "/app/out.pdf")

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	startErr := cmd.Start()
	if startErr != nil {
		log.Error("failed to start typst", "err", startErr.Error())
		return c.SendStatus(500)
	}
	if waitErr := cmd.Wait(); waitErr != nil {
		log.Error("failed to wait for typst..?", "err", waitErr.Error())
	}
	return readBack(c)
}

func readBack(c *fiber.Ctx) error {
	b, err := os.ReadFile("/app/out.pdf")
	if err != nil {
		log.Error("failed to read back file", "err", err.Error())
		return c.SendStatus(500)
	}
	_, writeErr := c.Write(b)
	if writeErr != nil {
		log.Error("failed to write response", "err", writeErr.Error())
		return c.SendStatus(500)
	}
	c.Response().Header.SetContentType("application/pdf")
	return c.SendStatus(200)
}
