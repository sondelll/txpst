package fs

import (
	"fmt"
	"os"
	"path"

	"github.com/charmbracelet/log"
)

func CopyAll(srcDir string, dstDir string) error {
	if !isValidDir(dstDir) || !isValidDir(dstDir) {
		return fmt.Errorf("INVALID_DIR")
	}
	dInfo, _ := os.ReadDir(srcDir)
	for _, item := range dInfo {
		fullSrc := path.Join(srcDir, item.Name())
		fullDst := path.Join(dstDir, item.Name())
		err := FileCopy(fullSrc, fullDst)
		if err != nil {
			log.Error("Failed to copy file",
				"src", fullSrc,
				"dst", fullDst,
				"err", err,
			)
		}
	}
	return nil
}

func FileCopy(srcFp string, dstFp string) error {
	if b, err := os.ReadFile(srcFp); err != nil {
		return err
	} else {
		return os.WriteFile(dstFp, b, 0755)
	}
}

func isValidDir(fp string) bool {
	if fi, err := os.Stat(fp); err != nil {
		return false
	} else if !fi.IsDir() {
		return false
	}

	return true
}
