package score
import (
    "fmt"
    //"path"
    "bytes"
    "github.com/gin-gonic/gin"
    
    "github.com/NCKU-NASA/nasa-judge-lib/schema/user"
    "github.com/NCKU-NASA/nasa-judge-lib/schema/lab"
    "github.com/NCKU-NASA/nasa-judge-lib/schema/lab/content"
    "github.com/NCKU-NASA/nasa-judge-lib/schema/score"

    "github.com/NCKU-NASA/nasa-judge-api/models/status"
    "github.com/NCKU-NASA/nasa-judge-api/middlewares/auth"
    //"github.com/NCKU-NASA/nasa-judge-api/utils/filepath"
    "github.com/NCKU-NASA/nasa-judge-api/utils/errutil"
)

var router *gin.RouterGroup

func Init(r *gin.RouterGroup) {
    router = r
    router.GET("/", auth.CheckIsTrust, help)
    router.POST("/get", auth.CheckIsTrust, get)
    router.POST("/judge", auth.CheckIsTrust, judge)
    router.POST("/canjudge", auth.CheckIsTrust, canjudge)
}

func help(c *gin.Context) {
    c.String(200, `
Usage: curl <host>/score/<api> -H 'Content-Type: application/json'

POST:
    get                         Get score and result from backend.
                                input:
                                    json:
                                        labId: labId you want to search
                                        username: username you want to search
                                        studentId: studentId you want to search
                                        score: score you want to search
                                        usedeadline: calc deadline score
                                        showresult: show all result
                                        showkeyisstudentId: use studentId for key on show
                                        max: show max score only
                                        groups: filter role for groups
                                            In element:
                                                name: group name
                                                show: show this score when user in this group
                                return: json
    canjudge                    Check is user can judge?
                                input:
                                    json:
                                        username: user name.
                                return: bool
    judge                       Judging.
                                input:
                                    json:
                                        labId: lab id that need judge.
                                        username: judge user.
                                        ipindex: user ipindex
                                        data: list. Same as the frontendvariable in config.yaml from <labId> dir.
                                return:
                                    json:
                                        alive: Is judge alive?
                                        result: Judge result.
                                        stdout: All stdout in judge.
                                        stderr: All stderr in judge.
`)
}

func get(c *gin.Context) {
    if status.Stop {
        c.JSON(200, nil)
        return
    }
    var nowfilter score.ScoreFilter
    err := c.ShouldBindJSON(&nowfilter)
    if err != nil {
        errutil.AbortAndStatus(c, 400)
        return
    }
    scores, err := nowfilter.GetScores(score.Scores{})
    c.JSON(200, scores)
}

func judge(c *gin.Context) {
    var judgedata struct {
        LabId string `json:"labId"`
        Username string `json:"username"`
        Contents content.Contents `json:"contents"`
    }
    err := c.ShouldBindJSON(&judgedata)
    if err != nil {
        errutil.AbortAndStatus(c, 400)
        return
    }
    userdata := user.User{
        Username: judgedata.Username,
    }
    userdata.Fix()
    if userdata.Username == "" {
        errutil.AbortAndStatus(c, 400)
        return
    }
    userdata, err = user.GetUser(userdata)
    if err != nil {
        errutil.AbortAndStatus(c, 409)
        return
    }
    labdata, err := lab.GetLab(judgedata.LabId)
    if err != nil {
        errutil.AbortAndStatus(c, 409)
        return
    }

    if judgeid, err := status.NewJudge(userdata); err == nil {
        defer status.RemoveJudge(userdata)
        nowscore := score.Score{
            UserID: userdata.ID,
            User: &userdata,
            LabID: labdata.ID,
            Lab: &labdata,
            Data: judgedata.Contents,
        }
        var stdout bytes.Buffer
        var stderr bytes.Buffer
        nowscore.Result, stdout, stderr, err = labdata.Judge(userdata, status.JudgingIDToEnv[judgeid], judgedata.Contents)
        if err != nil {
            fmt.Println(err)
            errutil.AbortAndStatus(c, 500)
            return
        }
        nowscore.Stdout = stdout.String()
        nowscore.Stderr = stderr.String()
        err = nowscore.Create()
        if err != nil {
            errutil.AbortAndStatus(c, 500)
            return
        }
        c.JSON(200, nowscore.ID)
        return
    } else {
        errutil.AbortAndStatus(c, 429)
        return
    }

    /*//test
    newresult := make(lab.CheckPoints)
    for key, value := range labdata.CheckPoints {
        if newresult[key] == nil {
            newresult[key] = make([]lab.CheckPoint, len(value))
        }
        for idx, point := range value {
            newresult[key][idx] = point
            newresult[key][idx].Commands = nil
            newresult[key][idx].Dependencies = nil
            newresult[key][idx].Correct = true
        }
    }
    nowscore := score.Score{
        UserID: userdata.ID,
        User: &userdata,
        LabID: labdata.ID,
        Lab: &labdata,
        Result: newresult,
        Data: judgedata.Contents,
        Stdout: "test",
        Stderr: "test",
    }
    err = nowscore.Create()
    if err != nil {
        errutil.AbortAndStatus(c, 500)
        return
    }
    c.JSON(200, nowscore.ID)*/
}

func canjudge(c *gin.Context) {
    if status.Stop {
        c.JSON(200, false)
        return
    }
    var userdata user.User
    err := c.ShouldBindJSON(&userdata)
    if err != nil {
        errutil.AbortAndStatus(c, 400)
        return
    }
    userdata = user.User{
        Username: userdata.Username,
    }
    userdata.Fix()
    if userdata.Username == "" {
        errutil.AbortAndStatus(c, 400)
        return
    }
    userdata, err = user.GetUser(userdata)
    if err != nil {
        errutil.AbortAndStatus(c, 409)
        return
    }
    c.JSON(200, !status.ExistJudge(userdata))
}

