import "reflect-metadata";
import SQL from "sql.js";
window.SQL = SQL;

if (typeof setImmediate === "undefined") {
  window.setImmediate = function (fn) {
    return setTimeout(fn, 0);
  };
}
