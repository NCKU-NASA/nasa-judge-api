package labs
import (
    "path"
    "github.com/gin-gonic/gin"
    
    "github.com/NCKU-NASA/nasa-judge-lib/schema/lab"

    "github.com/NCKU-NASA/nasa-judge-api/middlewares/auth"
    "github.com/NCKU-NASA/nasa-judge-api/utils/filepath"
    "github.com/NCKU-NASA/nasa-judge-api/utils/errutil"
)

var router *gin.RouterGroup

func init() {
    err := lab.Commit("all")
    if err != nil {
        panic(err)
    }
}

func Init(r *gin.RouterGroup) {
    router = r
    router.GET("/", auth.CheckIsTrust, help)
    router.GET("/:labId/get", auth.CheckIsTrust, get)
    router.GET("/:labId/commit", auth.CheckIsTrust, commit)
    router.GET("/:labId/file/:path", auth.CheckIsTrust, file)
}

func help(c *gin.Context) {
    c.String(200, `
Usage: curl <host>/labs/<api> -H 'Content-Type: application/json'

<labId> is lab ID. If <labId> is 'all' it mean all labs.

GET:
    <labId>/get                 Get lab info which you select.
                                return: dict
    <labId>/file/<path>         Download the file that is documented in the frontendvariable in config.yaml from <labId> dir.
                                return: file
    <labId>/file/description    Download the description file of <labId>.
                                return: file
`)
}

func commit(c *gin.Context) {
    labId := c.Param("labId")
    err := lab.Commit(labId)
    if err != nil {
        errutil.AbortAndError(c, &errutil.Err{
            Code: 500,
            Msg: err.Error(),
        })
        return
    }
    c.String(200, "Commit success")
}

func get(c *gin.Context) {
    labId := c.Param("labId")
    if labId == "all" {
        labs, err := lab.GetLabs()
        if err != nil {
            errutil.AbortAndError(c, &errutil.Err{
                Code: 500,
                Msg: err.Error(),
            })
            return
        }
        c.JSON(200, labs)
        return
    }
    nowlab, err := lab.GetLab(labId)
    if err != nil {
        errutil.AbortAndStatus(c, 404)
        return
    }
    c.JSON(200, nowlab)
}

func file(c *gin.Context) {
    labId := c.Param("labId")
    file := c.Param("path")

    if labId == "all" {
        errutil.AbortAndStatus(c, 404)
        return
    }
    labdata, err := lab.GetLab(labId)
    if err != nil {
        errutil.AbortAndStatus(c, 404)
        return
    }
    
    nowpath, err := filepath.VerifyPath(path.Join(lab.LabDir, labId, "download", file), path.Join(lab.LabDir, labId, "download"))
    if file == "description" {
        nowpath, err = filepath.VerifyPath(path.Join(lab.LabDir, labId, labdata.Description), path.Join(lab.LabDir, labId))
    }
    if err != nil {
        errutil.AbortAndStatus(c, 404)
        return
    }

    c.FileAttachment(nowpath, path.Base(nowpath))
}
