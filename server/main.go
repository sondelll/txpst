package main

import (
	"bytes"
	"os"
	"os/exec"
	"time"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New(fiber.Config{DisableStartupMessage: true})
	app.Post("/", run)
	addr := ":" + os.Getenv("PORT")
	app.Listen(addr)
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

	cmd := exec.Command("typst", "compile", "--font-path=/usr/fonts", "/app/doc.typ", "-")

	outBuf := bytes.NewBuffer([]byte{})
	cmd.Stdout = outBuf
	cmd.Stderr = os.Stderr

	startErr := cmd.Start()
	if startErr != nil {
		log.Error("failed to start typst", "err", startErr.Error())
		return c.SendStatus(500)
	}

	if waitErr := cmd.Wait(); waitErr != nil {
		log.Error("failed to wait for typst..?", "err", waitErr.Error())
	}

	return readBack(c, outBuf)
}

func readBack(c *fiber.Ctx, outBuffer *bytes.Buffer) error {
	_, writeErr := c.Writef("%v", outBuffer)
	if writeErr != nil {
		log.Error("failed to write response", "err", writeErr.Error())
		return c.SendStatus(500)
	}

	c.Response().Header.SetContentType("application/pdf")

	return c.SendStatus(200)
}
