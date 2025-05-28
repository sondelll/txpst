package txp

import (
	"testing"
)

var testTxpDoc = `
#text("Hello, World!", size:3em)

Hello, World, (but smaller)
`

func TestNew(t *testing.T) {
	tx, initErr := New()
	if initErr != nil {
		t.Logf("If typst is not installed, this is still correct. Error: %s", initErr.Error())
		t.SkipNow()
	}
	t.Logf("Version detected: %s", tx.DetectedVersion)
}

func TestCompile(t *testing.T) {
	tx, initErr := New()
	if initErr != nil {
		t.Logf("If typst is not installed, this is still correct. Error: %s", initErr.Error())
		t.SkipNow()
	}
	res, err := tx.Compile([]byte(testTxpDoc), "./", "png")
	if err != nil {
		t.Fatal(err)
	}

	//if err := os.WriteFile("../../test.pdf", res, 0755); err != nil {
	//	t.Logf("Failed to write test debug file, error: %s", err)
	//}

	t.Logf("Output has size %d", len(res))
}
