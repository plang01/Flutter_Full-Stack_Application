const express = require('express')
const cors = require('cors');
const bodyParser = require('body-parser');
const {connectToDb, getDb} = require('./db');
const { ObjectId } = require('mongodb');

const app = express()
const port = 3000;

// set header to avoid CORS policy error 
app.use(cors());
app.use((req,res,next) => {
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// process the return data, otherwise the data will be undefined
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// estabish db connection and assign it to db variable
let db
connectToDb((err) => {
    if (!err) {
        app.listen(port, () => {
            console.log(`Server running at http://localhost:${port}`)
           })
        db = getDb()
    }
})

app.get('/', (req, res) => {
 res.send('This is a greeting page!!!!')
})

// Retrieve data from MongoDB
app.get('/accounts', (req, res) => {
    let accounts = []
    // default page value is 0
    const page = req.query.p || 0
    const namesPerPage = 3


    db.collection('accounts')
        .find() // return an array 
        .sort({username: 1})
        // .skip(page * namesPerPage)
        // .limit(namesPerPage)
        //for each value, push it to names array
        .forEach(account => accounts.push(account)) 
        .then(() => {
            res.status(200).json(accounts)
        })
        .catch(() => {
            res.status(500).json({error: 'Unable to fetch the data'})
        })
})

// Get indidual data from id
app.get('/accounts/:id', (req,res) => {
    db.collection('accounts')
        .findOne({_id: new ObjectId(req.params.id)})
        .then(doc => {
            res.status(200).json(doc)
        })
        .catch(err => {
            res.status(500).json({error: 'Unable to fetch data'})
        })
});

// Post data to MongoDB
app.post('/accounts', (req,res) => {
    const account = req.body

    db.collection('accounts')
        .insertOne(account)
        .then(result => {
            res.status(201).json(result)
        })
        .catch(err => {
            res.status(500).json({err: 'Could not create new data'})
        })
})

app.patch('/accounts/:id', (req,res) => {
    const updates = req.body

    if(ObjectId.isValid(req.params.id)) {
        db.collection('accounts')
            .updateOne({_id: new ObjectId(req.params.id)}, {$set: updates})
            .then(result => {
                res.status(200).json(result)
            })
            .catch(err => {
                res.status(500).json({error: 'Could not update the data'})
            })
    }
    else {
        res.status(500).json({error: 'Not a valid id'})
    }
})
