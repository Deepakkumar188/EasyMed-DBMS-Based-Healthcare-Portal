// config/db.js - MySQL Connection Pool
require('dotenv').config();
const mysql = require('mysql2');

const pool = mysql.createPool({
    host:               process.env.DB_HOST     || 'localhost',
    port:               process.env.DB_PORT     || 3306,
    user:               process.env.DB_USER     || 'root',
    password:           process.env.DB_PASSWORD || '',
    database:           process.env.DB_NAME     || 'easymed_db',
    connectionLimit:    parseInt(process.env.DB_CONNECTION_LIMIT) || 10,
    waitForConnections: true,
    queueLimit:         0,
    charset:            'utf8mb4',
    timezone:           '+05:30',
    multipleStatements: false
});

const promisePool = pool.promise();

// Test connection on startup
pool.getConnection((err, connection) => {
    if (err) {
        console.error('❌ Database connection failed:', err.message);
        return;
    }
    console.log('✅ MySQL connected successfully — DB:', process.env.DB_NAME);
    connection.release();
});

// Utility: execute a query
async function query(sql, params = []) {
    try {
        const [rows] = await promisePool.execute(sql, params);
        return rows;
    } catch (err) {
        console.error('DB Query Error:', err.message);
        throw err;
    }
}

// Utility: begin transaction
async function getConnection() {
    return await promisePool.getConnection();
}

module.exports = { pool: promisePool, query, getConnection };
