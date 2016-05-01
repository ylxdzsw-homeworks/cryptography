import React from 'react'
import AppBar from 'material-ui/lib/app-bar'
import TextField from 'material-ui/lib/text-field'
import FlatButton from 'material-ui/lib/flat-button'
import List from 'material-ui/lib/lists/list'
import ListItem from 'material-ui/lib/lists/list-item'
import IconMenu from 'material-ui/lib/menus/icon-menu'
import MenuItem from 'material-ui/lib/menus/menu-item'
import IconButton from 'material-ui/lib/icon-button'
import Divider from 'material-ui/lib/divider'
import Dialog from 'material-ui/lib/dialog'
import Snackbar from 'material-ui/lib/snackbar'
import CircularProgress from 'material-ui/lib/circular-progress'
import MenuIcon from 'material-ui/lib/svg-icons/navigation/menu'
import AddIcon from 'material-ui/lib/svg-icons/content/add'
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
            files: [],
            nodelist: [],
            dialog: false,
            address: ""
        }

        this.upload      = this.upload.bind(this)
        this.dropHandler = this.dropHandler.bind(this)
        this.connect     = this.connect.bind(this)
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
            url: `http://${this.state.node}/files`, method: 'POST', contentType: 'application/json',
            data: JSON.stringify({filename: file.name})
        }).done(cb).fail(unlock)

        const upload = (data, cb) => $.ajax({
            url: `http://${this.state.node}/blobs/${data.id}`, method: 'PUT', data: file,
            processData: false, contentType: false
        }).done(cb).fail(unlock)

        lock()
        mkfile(data => upload(data, unlock))
    }

    dropHandler(e) {
        stopEvent(e)
        if(!e.dataTransfer.files) return
        if(!this.state.node) return

        const files = e.dataTransfer.files;

        [].forEach.call(files, this.upload)
    }

    connect() {
        this.setState({dialog: false, busy: this.state.busy + 1})
        $.get(`http://${this.state.address}/ping`)
            .done(() => this.setState({
                snackbar: `成功连接到 ${this.state.address}`,
                node: this.state.address,
                nodelist: this.state.nodelist.concat(this.state.address)}))
            .fail(()=>this.setState({snackbar: `连接 ${this.state.address} 失败`}))
            .always(()=>this.setState({busy: this.state.busy - 1}))
    }

    render() {
        const progresser = this.state.busy ? <CircularProgress style={styles.busy} color="white" size={0.48} /> : <span />
        const nodeguide = this.state.node ? "" : <img width={600} height={400} src="nodeguide.png" />
        const fileguide = !this.state.node || this.state.files.length ?
            "" : <img width={600} height={400} src="fileguide.png" />
        const menu = <IconMenu iconButtonElement={<IconButton><MenuIcon color="white" /></IconButton>}>
            {this.state.nodelist.length ? <Divider /> : ""}
            <MenuItem primaryText="添加新节点" leftIcon={<AddIcon />} onTouchTap={()=>this.setState({dialog: true})} />
        </IconMenu>
        const actions = [
            <FlatButton label="取消" secondary={true} onTouchTap={()=>this.setState({dialog: false})} />,
            <FlatButton label="连接" primary={true} onTouchTap={this.connect} />
        ]

        return (
            <div style={styles.container}>
                <AppBar
                    title={`SecShare - ${this.state.node || "尚未连接到节点"}`}
                    iconElementLeft={menu}
                    iconElementRight={progresser}
                />
                {nodeguide}
                {fileguide}
                <Dialog
                    title="连接新节点"
                    actions={actions}
                    open={this.state.dialog}
                    onRequestClose={()=>this.setState({dialog: false})}
                >
                    <TextField
                        name="address"
                        style={{ width: "80%" }}
                        floatingLabelText ="节点地址"
                        hintText="eg: secshare.ylxdzsw.com:233"
                        onChange={e=>this.setState({address: e.target.value})}
                        onEnterKeyDown={this.connect}
                    />
                </Dialog>
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
