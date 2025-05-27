package txpfiber

import (
	"fmt"
	"os"

	"github.com/charmbracelet/log"
	"github.com/google/uuid"
)

func NewWorkdir() string {
	id := fmt.Sprintf(".%s", uuid.New().String())
	if err := os.Mkdir(id, 0755); err != nil {
		log.Error("Mkdir failure", "err", err)
	}
	return id
}
