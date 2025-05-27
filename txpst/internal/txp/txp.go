package txp

import (
	"bytes"
	"fmt"
	"os/exec"
	"strings"
)

func New() (*TXP, error) {
	client := TXP{fontPaths: []string{"/fonts", "/usr/fonts"}}
	if err := client.check(); err != nil {
		return nil, err
	}

	return &client, nil
}

type TXP struct {
	DetectedVersion string `json:"version"`
	fontPaths       []string
}

func (t *TXP) check() error {
	readback, err := run("typst", nil, "-V")
	if err != nil {
		return err
	}
	versionString := strings.TrimPrefix(string(readback), "typst ")
	t.DetectedVersion = strings.TrimSpace(versionString)
	return nil
}

func (t *TXP) SetFontPaths(fps ...string) {
	t.fontPaths = fps
}

func (t *TXP) Compile(data []byte, wd string, format string) ([]byte, error) {
	fontArg := fmt.Sprintf("--font-path=%s", strings.Join(t.fontPaths, ":"))
	rootArg := fmt.Sprintf("--root=%s", wd)
	formatArg := fmt.Sprintf("--format=%s", format)
	res, err := run(
		"typst",
		data,
		"compile",
		formatArg,
		fontArg,
		rootArg,
		"-",
		"-",
	)
	if err != nil {
		return nil, err
	}
	return res, nil
}

func run(cmd string, bytesIn []byte, args ...string) ([]byte, error) {
	outBuf := bytes.NewBuffer([]byte{})
	executor := exec.Command(cmd, args...)
	executor.Stdout = outBuf
	if bytesIn != nil {
		executor.Stdin = bytes.NewReader(bytesIn)
	}
	err := executor.Run()

	return outBuf.Bytes(), err
}
