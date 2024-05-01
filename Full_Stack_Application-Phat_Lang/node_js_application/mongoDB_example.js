// const express = require('express')
// const cors = require('cors');
// const bodyParser = require('body-parser');
// const {connectToDb, getDb} = require('./db');
// const { ObjectId } = require('mongodb');

// const app = express()
// const port = 3000;

// // set header to avoid CORS policy error 
// app.use(cors());
// app.use((req,res,next) => {
//     res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
//     next();
// });

// // process the return data, otherwise the data will be undefined
// app.use(bodyParser.urlencoded({ extended: true }));
// app.use(bodyParser.json());

// // estabish db connection and assign it to db variable
// let db
// connectToDb((err) => {
//     if (!err) {
//         app.listen(port, () => {
//             console.log(`Server running at http://localhost:${port}`)
//            })
//         db = getDb()
//     }
// })


// app.get('/user/book', (req, res) => {
//     // res.json(books);

//     let books = []
//     // default page value is 0
//     const page = req.query.p || 0
//     const booksPerPage = 3


//     db.collection('books')
//         .find() // return an array 
//         // .sort({author: 1})
//         .skip(page * booksPerPage)
//         .limit(booksPerPage)
//         //for each value, push it to books array
//         .forEach(book => books.push(book)) 
//         .then(() => {
//             res.status(200).json(books)
//         })
//         .catch(() => {
//             res.status(500).json({error: 'Unable to fetch the data'})
//         })
// })

// app.get('/books/:id', (req,res) => {
//     db.collection('books')
//         .findOne({_id: new ObjectId(req.params.id)})
//         .then(doc => {
//             res.status(200).json(doc)
//         })
//         .catch(err => {
//             res.status(500).json({error: 'Unable to fetch data'})
//         })
// });

// app.post('/books', (req,res) => {
//     const book = req.body

//     db.collection('books')
//         .insertOne(book)
//         .then(result => {
//             res.status(201).json(result)
//         })
//         .catch(err => {
//             res.status(500).json({err: 'Could not create new data'})
//         })
// })

// app.patch('/books/:id', (req,res) => {
//     const updates = req.body

//     if(ObjectId.isValid(req.params.id)) {
//         db.collection('books')
//             .updateOne({_id: new ObjectId(req.params.id)}, {$set: updates})
//             .then(result => {
//                 res.status(200).json(result)
//             })
//             .catch(err => {
//                 res.status(500).json({error: 'Could not update the data'})
//             })
//     }
//     else {
//         res.status(500).json({error: 'Not a valid id'})
//     }
// })