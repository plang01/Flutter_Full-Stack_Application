const { MongoClient } = require('mongodb')

let dbConnection

module.exports = {
    connectToDb: (cb) => {
        //Make connection to local databse
        MongoClient.connect('mongodb://localhost:27017/authentication')
            .then((client) => {
                // assign the client database to dbConnection
                dbConnection = client.db()
                // return the call back function argument
                return cb()
            })
            .catch(err => {
                console.log(err)
                return cb(err)
            })
    },
    getDb: () => dbConnection
}