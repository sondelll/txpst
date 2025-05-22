package main

import (
	"bytes"
	"os"
	"os/exec"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/idempotency"
	"github.com/sondelll/txstp/server/internal/txputil"
)

func main() {
	app := fiber.New(fiber.Config{DisableStartupMessage: true})
	idem := app.Use(idempotency.New(idempotency.ConfigDefault))
	idem.Post("/cert", certHandler)
	app.Get("/example", exampleHandler)
	//app.Post("/example", exampleHandler)
	addr := ":" + os.Getenv("PORT")
	app.Listen(addr)
}

func exampleHandler(c *fiber.Ctx) error {
	if err := txputil.PlaceAll(c); err != nil {
		return c.SendStatus(500)
	}

	outBuf, compileErr := compile("/app/example.typ")

	if compileErr != nil {
		return c.SendStatus(500)
	}
	txputil.ClearAll()

	return readBack(c, outBuf)
}

func certHandler(c *fiber.Ctx) error {
	auth := c.Get("Authorization")
	if auth != "1f7f1a" {
		return c.SendStatus(401)
	}

	if err := txputil.PlaceAll(c); err != nil {
		return c.SendStatus(500)
	}

	out, compileErr := compile("/app/doc.typ")
	if compileErr != nil {
		return c.SendStatus(500)
	}

	txputil.ClearAll()

	return readBack(c, out)
}

func compile(fp string) (*bytes.Buffer, error) {
	cmd := exec.Command("typst", "compile", "--font-path=/usr/fonts", fp, "-")

	outBuf := bytes.NewBuffer([]byte{})
	cmd.Stdout = outBuf
	cmd.Stderr = os.Stderr

	startErr := cmd.Start()
	if startErr != nil {
		log.Error("failed to start typst", "err", startErr.Error())
		return nil, startErr
	}

	if waitErr := cmd.Wait(); waitErr != nil {
		log.Error("failed to wait for typst..?", "err", waitErr.Error())
		return nil, waitErr
	}
	return outBuf, nil
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
