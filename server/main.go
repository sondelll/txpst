package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"

	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
	"github.com/sondelll/txstp/server/internal/txputil"
)

func main() {
	app := fiber.New(fiber.Config{DisableStartupMessage: true})

	app.Post("/cert", certHandler)
	app.Get("/example", exampleHandler)
	//app.Post("/example", exampleHandler)
	addr := ":" + os.Getenv("PORT")
	app.Listen(addr)
}

func exampleHandler(c *fiber.Ctx) error {
	wd := txputil.NewWorkdir()
	if err := txputil.PlaceAll(c, wd); err != nil {
		return c.SendStatus(500)
	}

	outBuf, compileErr := compile("/app/example.typ", wd)

	if compileErr != nil {
		return c.SendStatus(500)
	}

	txputil.ClearAll(wd)

	return readBack(c, outBuf)
}

func certHandler(c *fiber.Ctx) error {
	auth := c.Get("Authorization")
	if auth != "1f7f1a" {
		return c.SendStatus(401)
	}
	wd := txputil.NewWorkdir()

	if err := txputil.PlaceAll(c, wd); err != nil {
		return c.SendStatus(500)
	}
	out, compileErr := compile("/app/doc.typ", wd)
	if compileErr != nil {
		return c.SendStatus(500)
	}
	workedDir := fmt.Sprintf("./.%s", wd)
	txputil.ClearAll(workedDir)

	return readBack(c, out)
}

func compile(fp string, id string) (*bytes.Buffer, error) {
	rootArg := fmt.Sprintf("--root=./%s", id)
	typFileContent, tfcErr := os.ReadFile(fp)
	if tfcErr != nil {
		return nil, tfcErr
	}

	cmd := exec.Command("typst", "compile", "--font-path=/usr/fonts", rootArg, "-", "-")

	outBuf := bytes.NewBuffer([]byte{})
	cmd.Stdout = outBuf
	inBuf := bytes.NewBuffer([]byte{})
	inBuf.Write(typFileContent)
	cmd.Stdin = inBuf
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
