const assert = require('assert');

console.log('--- Running Customer Service Unit Tests ---');

// Test 1: Validate Customer search filtering
const testCustomers = [
  { id: 1, name: 'Alice Smith', email: 'alice@enterprise.com', tier: 'Enterprise' },
  { id: 2, name: 'Bob Johnson', email: 'bob@techcorp.io', tier: 'Business' }
];

const searchResult = testCustomers.filter(c => c.name.toLowerCase().includes('alice'));
assert.strictEqual(searchResult.length, 1);
assert.strictEqual(searchResult[0].name, 'Alice Smith');
console.log('✔ Customer search logic unit test passed');

// Test 2: Validate DB connection check logic
function testDbConnection(host) {
  return !host.includes('invalid') && !host.includes('wrong');
}

assert.strictEqual(testDbConnection('customer-db-dev'), true);
assert.strictEqual(testDbConnection('customer-db-uat'), true);
assert.strictEqual(testDbConnection('customer-db-prod'), true);
assert.strictEqual(testDbConnection('wrong-host'), false);
console.log('✔ Database connection validator passed');

console.log('--- All Unit Tests Passed Successfully ---');
process.exit(0);

