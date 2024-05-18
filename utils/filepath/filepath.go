package filepath

import (
    "fmt"
    "path/filepath"
)

func VerifyPath(path, root string) (string, error) {
    path, err := filepath.Abs(path)
    if err != nil {
        return path, err
    }
    root, err = filepath.Abs(root)
    if err != nil {
        return path, err
    }
    path = filepath.Clean(path)
    root = filepath.Clean(root)
    tmppath := path
    safe := false
    for tmppath != "/" {
        tmppath = filepath.Dir(tmppath)
        if tmppath == root {
            safe = true
            break
        }
    }
    if !safe {
        return path, fmt.Errorf("Unsafe or invalid path specified")
    }
    return path, nil
}
