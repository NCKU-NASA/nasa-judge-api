package status
import (
    "github.com/gin-gonic/gin"

    "github.com/NCKU-NASA/nasa-judge-api/middlewares/auth"
    "github.com/NCKU-NASA/nasa-judge-api/models/status"
    "github.com/NCKU-NASA/nasa-judge-api/utils/errutil"
)

var router *gin.RouterGroup

func Init(r *gin.RouterGroup) {
    router = r
    router.GET("/", auth.CheckIsTrust, help)
    router.GET("/stop", auth.CheckIsTrust, stop)
    router.GET("/start", auth.CheckIsTrust, start)
    router.GET("/alive", auth.CheckIsTrust, alive)
    router.GET("/workerlist", auth.CheckIsTrust, workerlist)
    router.GET("/showjudgingusers", auth.CheckIsTrust, showjudgingusers)
    router.GET("/setenv", setenv)
}

func help(c *gin.Context) {
    c.String(200, `
Usage: curl <host>/status/<api> -H 'Content-Type: application/json'

GET:
    stop                        Run stop and wait until result become true before stop this service.
                                return: bool
    start                       Start after run stop.
                                return: bool
    alive                       Check service alive.
                                return: bool
    workerlist                  Get all of workers which is idle.
                                return: list
    showjudgingusers            Get all judgingusers.
                                return: list
`)
}

func stop(c *gin.Context) {
    status.Stop = true
    c.JSON(200, true)
}

func start(c *gin.Context) {
    status.Stop = false
    c.JSON(200, true)
}

func alive(c *gin.Context) {
    c.JSON(200, !status.Stop)
}

func workerlist(c *gin.Context) {
    c.JSON(200, status.Worker)
}

func showjudgingusers(c *gin.Context) {
    result := make([]struct{
        Name string `json:"name"`
        JudgeID string `json:"judgeid"`
    }, len(status.Judging))
    for idx, nowuser := range status.Judging {
        result[idx] = struct{
            Name string `json:"name"`
            JudgeID string `json:"judgeid"`
        } {
            Name: nowuser.Username,
            JudgeID: status.UserToJudgingID[nowuser.ID],
        }
    }
    c.JSON(200, result)
}

func setenv(c *gin.Context) {
    var postdata struct {
        ID string `json:"id"`
        Envs map[string]string `json:"envs"`
    }
    err := c.ShouldBindJSON(&postdata)
    if err != nil {
        errutil.AbortAndStatus(c, 400)
        return
    }
    if env, exist := status.JudgingIDToEnv[postdata.ID]; exist {
        for key, data := range postdata.Envs {
            env[key] = data
        }
    }
    c.JSON(200, "Success")
}
