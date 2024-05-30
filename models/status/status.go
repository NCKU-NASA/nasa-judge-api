package status
import (
    "sync"
    "fmt"
    "os"
    "regexp"

    "github.com/google/uuid"
    "gopkg.in/yaml.v3"
    
    "github.com/NCKU-NASA/nasa-judge-lib/schema/user"

    "github.com/NCKU-NASA/nasa-judge-api/utils/config"
)

var Stop bool
var Worker map[string][]string
var Judging []user.User
var UserToJudgingID map[uint]string
var JudgingIDToEnv map[string]map[string]string
var lock *sync.RWMutex

func init() {
    lock = new(sync.RWMutex)
    Stop = false
    workerconfig, err := os.ReadFile(config.WorkerConfigPath)
    if err != nil {
        panic(err)
    }
    err = yaml.Unmarshal([]byte(workerconfig), &Worker)
    if err != nil {
        panic(err)
    }
    UserToJudgingID = make(map[uint]string)
    JudgingIDToEnv = make(map[string]map[string]string)
}

func NewJudge(userdata user.User) (id string, err error) {
    reg := regexp.MustCompile(`[^a-zA-Z0-9]`)
    id = reg.ReplaceAllString(uuid.NewString(), "")
    lock.Lock()
    defer lock.Unlock()
    if _, exist := UserToJudgingID[userdata.ID]; exist {
        err = fmt.Errorf("Exist")
        return
    }
    for _, exist := JudgingIDToEnv[id]; exist; _, exist = JudgingIDToEnv[id] {
        id = reg.ReplaceAllString(uuid.NewString(), "")
    }
    Judging = append(Judging, userdata)
    UserToJudgingID[userdata.ID] = id
    JudgingIDToEnv[id] = make(map[string]string)
    return
}

func RemoveJudge(userdata user.User) {
    lock.Lock()
    defer lock.Unlock()
    for idx, nowuser := range Judging {
        if nowuser.ID == userdata.ID {
            Judging = append(Judging[:idx], Judging[idx+1:]...)
            break
        }
    }
    delete(JudgingIDToEnv, UserToJudgingID[userdata.ID])
    delete(UserToJudgingID, userdata.ID)
}

func ExistJudge(userdata user.User) bool {
    lock.RLock()
    defer lock.RUnlock()
    _, exist := UserToJudgingID[userdata.ID]
    return exist
}
