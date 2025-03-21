from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

subsidy_data = [
    {
        "name": "Ayushman Bharat Pradhan Mantri Jan Arogya Yojana (PM-JAY)",
        "description": "Provides health coverage up to INR 5 lakh per family per year for secondary and tertiary hospitalization.",
        "amount": 500000,
        "category": "Healthcare"
    },
    {
        "name": "Pradhan Mantri Suraksha Bima Yojana (PMSBY)",
        "description": "Accident insurance scheme offering coverage for accidental death and disability.",
        "amount": 200000,
        "category": "Healthcare"
    },
    {
        "name": "Central Government Health Scheme (CGHS)",
        "description": "Comprehensive healthcare facilities for central government employees and pensioners.",
        "amount": 0,  # Direct healthcare provision, not monetary
        "category": "Healthcare"
    }
]

@app.route('/get_subsidies', methods=['GET'])
def get_subsidies():
    location = request.args.get('location', '').strip().lower()
    income = request.args.get('income', '').strip()
    age = request.args.get('age', '').strip()
    category = request.args.get('category', '').strip().lower()

    print(f"Received request: location={location}, income={income}, age={age}, category={category}")

    # Filter based on provided parameters
    filtered_subsidies = [
        s for s in subsidy_data
        if (category == "" or s["category"].lower() == category)
    ]

    print(f"Filtered Subsidies: {filtered_subsidies}")  # Debugging output

    return jsonify(filtered_subsidies)

if __name__ == '__main__':
    app.run(debug=True)
