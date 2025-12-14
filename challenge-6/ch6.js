/**
 * Challenge 6: Transaction Analysis
 * Verifies internal call to registry contract with registerData method
 */

const https = require('https');

const RPC_URL = 'rpc.ankr.com';
const RPC_PATH = '/eth_sepolia/7d2ecae2021d16ed872c18c4cfb8c3f745a782dacbf3b627ef86925b494a8463';
const REGISTRY_CONTRACT = '0x3819c7071f2bc39c83187bf5b5aea79fa3e37c42';

function rpcCall(method, params = []) {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify({
            jsonrpc: '2.0',
            id: 1,
            method: method,
            params: params
        });

        const req = https.request({
            hostname: RPC_URL,
            path: RPC_PATH,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': postData.length
            }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try {
                    const response = JSON.parse(data);
                    resolve(response.error ? null : response.result);
                } catch (e) {
                    reject(e);
                }
            });
        });

        req.on('error', reject);
        req.write(postData);
        req.end();
    });
}

async function analyzeTransaction(txHash) {
    console.log('Challenge 6: Transaction Analysis');
    console.log('TX:', txHash);

    try {
        const tx = await rpcCall('eth_getTransactionByHash', [txHash]);
        const receipt = await rpcCall('eth_getTransactionReceipt', [txHash]);
        
        if (!tx || !receipt || parseInt(receipt.status, 16) !== 1) {
            console.log('❌ Transaction not found or failed');
            return false;
        }

        console.log('✅ Transaction verified - Block:', parseInt(tx.blockNumber, 16));

        // Get traces
        const traces = await rpcCall('trace_transaction', [txHash]);
        
        if (traces && traces.length > 0) {
            for (const trace of traces) {
                if (trace.action?.to?.toLowerCase() === REGISTRY_CONTRACT.toLowerCase()) {
                    const input = trace.action.input;
                    const methodSig = input.substring(0, 10);
                    
                    console.log('✅ Internal call to registry found');
                    console.log('   Method signature:', methodSig);
                    
                    if (methodSig.toLowerCase() === '0x21f3f819') {
                        console.log('   Method name: registerData(bytes32,bytes32,address,address)');
                        
                        const params = input.substring(10);
                        console.log('\nRegistered Data:');
                        console.log('  Challenge 01:', '0x' + params.substring(0, 64));
                        console.log('  Challenge 02:', '0x' + params.substring(64, 128));
                        console.log('  Challenge 03:', '0x' + params.substring(152, 192));
                        console.log('  Challenge 04:', '0x' + params.substring(216, 256));
                        
                        console.log('\n🎉 CHALLENGE 6 COMPLETE!');
                        return true;
                    }
                }
            }
        }
        
        console.log('❌ No internal call to registry found');
        return false;

    } catch (error) {
        console.log('❌ Error:', error.message);
        return false;
    }
}

// Main
const txHash = process.argv[2] || '0xda1b62845a80a3633605acacc01cb7e1be015030d44e6468be6a0f30428a992c';
analyzeTransaction(txHash).then(result => process.exit(result ? 0 : 1));