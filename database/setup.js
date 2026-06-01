// database/setup.js - Run this to initialize the database
require('dotenv').config();
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function setupDatabase() {
  console.log('🏥 EasyMed Database Setup Starting...\n');
  
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      port: process.env.DB_PORT || 3306,
      multipleStatements: true
    });

    console.log('✅ Connected to MySQL server');

    const schemaSQL = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
    await connection.query(schemaSQL);
    console.log('✅ Database schema created successfully');

    const seedSQL = fs.readFileSync(path.join(__dirname, 'seed.sql'), 'utf8');
    await connection.query(seedSQL);
    console.log('✅ Sample data seeded successfully');

    console.log('\n🎉 EasyMed Database Setup Complete!');
    console.log('\n📋 Default Login Credentials:');
    console.log('   Admin:   admin@easymed.com / Admin@123');
    console.log('   Doctor:  rajesh.sharma@easymed.com / Doctor@123');
    console.log('   Patient: arjun.mehta@email.com / Patient@123');
    
  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    process.exit(1);
  } finally {
    if (connection) await connection.end();
  }
}

setupDatabase();
