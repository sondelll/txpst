package txputil

import (
	"github.com/charmbracelet/log"
	"github.com/gofiber/fiber/v2"
)

func PlaceAll(c *fiber.Ctx) error {
	if err := PlaceContext(c); err != nil {
		log.Error("Context failure", "err", err)
		return err
	}
	if err := PlaceUserData(c); err != nil {
		log.Error("User data failure", "err", err)
		return err
	}
	return nil
}
