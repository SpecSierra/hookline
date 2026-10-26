.pragma library

// Mirrors block_lists::isEnabled in the daemon: the user's choice, otherwise
// the lists of the home country
function isEnabled(setting, list) {
    var choice = setting.get("block_list_" + list.id, "")
    if (choice !== "")
        return choice === "true"
    var home = setting.get("home_country", setting.get("location", ""))
    return home !== "" && list.country.toUpperCase() === home.toUpperCase()
}

function index(setting) {
    try {
        return JSON.parse(setting.get("block_lists_index", "[]"))
    } catch (e) {
        return []
    }
}

function summary(setting, list) {
    var updated = setting.get("block_list_updated_" + list.id, "")
    if (updated === "")
        return qsTr("Not downloaded yet")
    var count = parseInt(setting.get("block_list_count_" + list.id, "0"))
    var date = Qt.formatDateTime(new Date(updated), Qt.DefaultLocaleShortDate)
    return qsTr("%n entries", "", count) + " · " + qsTr("updated %1").arg(date)
}
