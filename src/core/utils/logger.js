'use strict';

let LOG_LEVEL = 'info';

export const LEVELS = {
  error: {
    color: "#dd0011",
    sort: 4
  },
  debug: {
    color: "#009922",
    sort: 0
  },
  verbose: {
    color: "#eee",
    sort: -1
  },
  info: {
    color: "#1122ff",
    sort: 1
  },
  warning: {
    color: "#ffaa33",
    sort: 2
  }
};

let console_log;

if(!window.console || !window.console.log)
  console_log = function() {};
else
  console_log = window.console.log.bind(window.console);


let showLog = function(level){
  return LEVELS[LOG_LEVEL].sort <= LEVELS[level].sort;
}

export function log(level, ...msgs){
  showLog(level) && console_log(`%c ${ Date() } [${ level }]`, `color: ${LEVELS[level].color}`, ...msgs);
}


export function setLogLevel(level){
  if(LEVELS[level]) LOG_LEVEL = level;
}

export function debug(...msgs){
  log('debug', ...msgs);
}

export function error(...msgs){
  log('error', ...msgs);
}

export function warning(...msgs){
  log('warning', ...msgs);
}

export function info(...msgs){
  log('info', ...msgs);
}

export function verbose(...msgs){
  log('verbose', ...msgs);
}