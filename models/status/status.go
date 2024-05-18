package status
import (
    "os"
    "gopkg.in/yaml.v3"
    
    "github.com/NCKU-NASA/nasa-judge-lib/schema/user"

    "github.com/NCKU-NASA/nasa-judge-api/utils/config"
)

var Stop bool
var Worker map[string][]string
var Judging []user.User

func init() {
    Stop = false
    workerconfig, err := os.ReadFile(config.WorkerConfigPath)
    if err != nil {
        panic(err)
    }
    err = yaml.Unmarshal([]byte(workerconfig), &Worker)
    if err != nil {
        panic(err)
    }
}
