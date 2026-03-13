from flask import Flask
from policy_service import create_policy

app = Flask(__name__)

@app.route("/policy/create", methods=["POST"])
def create():
    return create_policy()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)