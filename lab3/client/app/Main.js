import React from 'react'
import AppBar from 'material-ui/lib/app-bar'
import TextField from 'material-ui/lib/text-field'
import FlatButton from 'material-ui/lib/flat-button'
import RaisedButton from 'material-ui/lib/raised-button'
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
import PowerIcon from 'material-ui/lib/svg-icons/action/power-settings-new'
import SyncIcon from 'material-ui/lib/svg-icons/notification/sync'
import PlayIcon from 'material-ui/lib/svg-icons/av/play-arrow'
import {stopEvent} from './utils.js'

const styles = {
    container: {
        maxWidth: 600,
        minWidth: 480,
        margin: 'auto'
    },
    busy: {
        zIndex: 9999
    },
    operations: {
        float: 'right',
        padding: '10px'
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
            address: "", // for input component
            online: false
        }

        this.upload      = this.upload.bind(this)
        this.dropHandler = this.dropHandler.bind(this)
        this.connect     = this.connect.bind(this)
        this.login       = this.login.bind(this)
        this.logout      = this.logout.bind(this)
        this.sync        = this.sync.bind(this)
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
        $.get(`http://${this.state.address}/status`)
            .done(data=>{
                this.setState({
                    snackbar: `成功连接到 ${this.state.address}`,
                    node: this.state.address,
                    nodelist: this.state.nodelist.concat(this.state.address),
                    online: data.online
                })
                this.sync()
            })
            .fail(()=>this.setState({snackbar: `连接 ${this.state.address} 失败`}))
            .always(()=>this.setState({busy: this.state.busy - 1}))
    }

    switchTo(addr) {
        this.setState({busy: this.state.busy + 1})
        $.get(`http://${addr}/status`)
            .done(data=>{
                this.setState({
                    snackbar: `成功切换到 ${addr}`,
                    node: addr,
                    online: data.online})
                this.sync()
            })
            .fail(()=>this.setState({snackbar: `切换 ${addr} 失败`}))
            .always(()=>this.setState({busy: this.state.busy - 1}))
    }

    login() {
        $.ajax({
            url: `http://${this.state.node}/connection`, method: 'PUT'
        }).done(()=>{
            this.setState({snackbar: "上线成功",online: true})
            this.sync()
        }).fail(()=>this.setState({
            snackbar: "上线失败，请检查索引节点"
        }))
    }

    logout() {
        $.ajax({
            url: `http://${this.state.node}/connection`, method: 'DELETE'
        }).done(()=>this.setState({
            snackbar: "注销成功",
            online: false
        })).fail(()=>this.setState({
            snackbar: "注销失败"
        }))
    }

    sync() {
        $.get(`http://${this.state.node}/files`)
            .done(data=>console.log(data))
    }

    render() {
        const progresser = this.state.busy ? <CircularProgress style={styles.busy} color="white" size={0.48} /> : <span />
        const nodeguide = this.state.node ? "" : <img width={600} height={400} src="nodeguide.png" />
        const fileguide = !this.state.node || this.state.files.length ?
            "" : <img width={600} height={400} src="fileguide.png" />
        const menu = <IconMenu
            iconButtonElement={<IconButton><MenuIcon color="white" /></IconButton>}
            anchorOrigin={{horizontal: 'left', vertical: 'bottom'}}
        >
            {this.state.nodelist.map((x,i)=><MenuItem
                key={i}
                primaryText={x}
                leftIcon={<PlayIcon style={{ fill: x==this.state.node ? null : 'transparent'}} />}
                onTouchTap={()=>{
                    this.setState({ address: x })
                    this.switchTo(x)
                }}
            />)}
            {this.state.nodelist.length ? <Divider /> : ""}
            <MenuItem primaryText="添加新节点" leftIcon={<AddIcon />} onTouchTap={()=>this.setState({dialog: true})} />
        </IconMenu>
        const actions = [
            <FlatButton label="取消" secondary={true} onTouchTap={()=>this.setState({dialog: false})} />,
            <FlatButton label="连接" primary={true} onTouchTap={this.connect} />
        ]
        const operations = !this.state.node ? "" : <div style={styles.operations}>
            {!this.state.online ? "" : <RaisedButton label="同步" icon={<SyncIcon />} primary={true} onTouchTap={this.sync} />}
            <RaisedButton
                label={this.state.online ? "注销" : "上线"}
                icon={<PowerIcon />}
                secondary={true}
                style={{ marginLeft: 10 }}
                onTouchTap={this.state.online ? this.logout : this.login}
            />
        </div>

        return (
            <div style={styles.container}>
                <AppBar
                    title={`SecShare - ${this.state.node || "尚未连接到节点"} (${this.state.online ? "在线" : "离线"})`}
                    iconElementLeft={menu}
                    iconElementRight={progresser}
                />
                {operations}
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
                        onKeyDown={e=>e.keyCode==13 && this.connect()}
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
