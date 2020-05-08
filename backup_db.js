const fs = require('fs');

const dir = './db_backups';

if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir);
}

const interval = 12; // DB backups once every 12 hours

setInterval(() => {
    fs.createReadStream('server.db').pipe(fs.createWriteStream(`${dir}/${GetLogDate()}.db`));
    console.log(`Created backup at ${GetLogDate()}`);
}, interval * 1000 * 60 * 60);

console.log("Backups started.")

/**
 * Gets a nicely formatted time string.
 * 
 * @return {string}
 */

function GetTime()
{
    const date = new Date();

    let hour = date.getHours();
    hour = (hour < 10 ? "0" : "") + hour;

    let min  = date.getMinutes();
    min = (min < 10 ? "0" : "") + min;

    let sec  = date.getSeconds();
    sec = (sec < 10 ? "0" : "") + sec;

    return ` ${hour}-${min}-${sec}`;
}

/**
 * Gets a nicely formatted date string for log filenames.
 * 
 * @return {string}
 */

function GetDate()
{
    const date = new Date();

    let year = date.getFullYear();

    let month = date.getMonth() + 1;
    month = (month < 10 ? "0" : "") + month;

    let day  = date.getDate();
    day = (day < 10 ? "0" : "") + day;

    return `${year}-${month}-${day}`;
}

function GetLogDate()
{
    return `${GetDate()}-${GetTime()}`;
}
