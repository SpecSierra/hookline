.pragma library

// How well a lookup source works, from the "status" field of the source index
function text(status, note) {
    if (note)
        return note
    switch (status) {
    case "working": return qsTr("Working")
    case "limited": return qsTr("Partly working")
    case "blocked": return qsTr("Blocked by the website")
    case "broken": return qsTr("Not working")
    }
    return ""
}

function isProblem(status) {
    return status === "blocked" || status === "broken"
}
