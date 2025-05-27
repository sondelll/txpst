package txpfiber

import "github.com/gofiber/fiber/v2"

func Define(app *fiber.App) error {
	app.Post("/templated/:templateName", HandleCompile)
	return nil
}
