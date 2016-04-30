import React from 'react'
import AppBar from 'material-ui/lib/app-bar'
import List from 'material-ui/lib/lists/list'
import ListItem from 'material-ui/lib/lists/list-item'
import Divider from 'material-ui/lib/divider'
import Snackbar from 'material-ui/lib/snackbar'
import CircularProgress from 'material-ui/lib/circular-progress'
import {stopEvent} from './utils.js'

const styles = {
    container: {
        maxWidth: 600,
        minWidth: 480,
        margin: 'auto'
    },
    busy: {
        zIndex: 9999
    }
}

class Main extends React.Component {
    constructor(props, context) {
        super(props, context)

        this.state = {
            snackbar: "",
            node: "",
            busy: 0,
            files: []
        }

        this.upload      = this.upload.bind(this)
        this.dropHandler = this.dropHandler.bind(this)
    }

    componentDidMount() {
        document.body.addEventListener('dragenter', stopEvent, true)
        document.body.addEventListener('dragover', stopEvent, true)
        document.body.addEventListener('drop', this.dropHandler, true)
    }

    upload(file) {
        const lock = () => this.setState({
            busy: this.state.busy + 1,
            snackbar: "正在上传文件"
        })

        const unlock = () => this.setState({
            busy: this.state.busy - 1,
            snackbar: "文件上传成功"
        })

        const mkfile = (cb) => $.ajax({
            url: `http://${this.state.node}/files`, method: 'POST', data: file.name
        }).done(cb)

        const upload = (data, cb) => $.ajax({
            url: `http://${this.state.node}/blob/${data.blob}`, method: 'PUT', data: file,
            processData: false, contentType: false
        }).done(cb)

        lock()
        mkfile((data) => upload(data, unlock))
    }

    dropHandler(e) {
        stopEvent(e)
        if(!e.dataTransfer.files) return
        if(!this.state.node) return

        const files = e.dataTransfer.files;

        [].forEach.call(files, (file) => {
            this.upload(file)
        })
    }

    render() {
        const progresser = this.state.busy ? <CircularProgress style={styles.busy} color="#fff" size={0.48} /> : <span />
        const nodeguide = this.state.node ? "" : <img width={600} height={400} src="nodeguide.png" />
        const fileguide = !this.state.node || this.state.files.length ?
            "" : <img width={600} height={400} src="fileguide.png" />

        return (
            <div style={styles.container}>
                <AppBar
                    title={`SecShare - ${this.state.node || "尚未连接到节点"}`}
                    iconElementRight={progresser}
                />
                {nodeguide}
                {fileguide}
                <Snackbar
                    open={!!this.state.snackbar}
                    message={this.state.snackbar}
                    action="确定"
                    autoHideDuration={2000}
                    onRequestClose={()=>this.setState({snackbar: ""})}
                />
            </div>
        )
    }
}

export default Main
