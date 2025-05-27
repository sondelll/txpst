package fs

import "os"

func UnbotheredDelete(fp string) {
	os.Remove(fp)
}
