import React from 'react'
import {stop} from './utils.js'

class Main extends React.Component {
    constructor(props, context) {
        super(props, context)

        this.state = {}

        this.dropHandler = this.dropHandler.bind(this)
    }

    upload(id, file) {
        $.ajax({
            url: v1`blobs/`+id, method: 'PUT', data: file,
            processData: false, contentType: false
        }).done((data) => {
            console.log(data)
        })
    }

    dropHandler(e) {
        stop(e)
        if(!e.dataTransfer.files) return

        const file = e.dataTransfer.files[0]
        const reader = new FileReader()

        $.ajax({
            url: v1`info`, method: 'POST', contentType: 'application/json',
            data: JSON.stringify({filename: file.name})
        }).done((data) => {
            this.upload(data.id, file)
        })
    }

    render() {
        return (
            <div
                onDragEnter={stop}
                onDragOver={stop}
                onDrop={this.dropHandler}>
                Hello World
            </div>
            <div onClick={}>
                play
            </div>
        )
    }
}

export default Main
