from flask import Flask, jsonify, request
app = Flask(__name__)

@app.get("/health")
def health():
    return jsonify(ok=True)

@app.get("/sum")
def sum_route():
    a = int(request.args.get("a", 0))
    b = int(request.args.get("b", 0))
    return jsonify(sum=a+b)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
