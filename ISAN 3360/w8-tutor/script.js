const KEY = "sk-di-7lzVxJBU0d4l0Uxx5UdlV5alzXL6jcxg";
const model = "google/gemma-3-12b-it";
const API = "https://api.deepinfra.com/v1/openai/chat/completions";

const messages = [{
    role: "system",
    content:
        "You are a patient tutor for students new to HTML and CSS. " +
        "Answer in 3 short sentences, in plain text, with a tiny example."
}];

document.querySelector("#ask").addEventListener("submit", async (event) => {
    event.preventDefault();

    const box = document.querySelector("#question");
    const question = box.value.trim();

    if (!question) {
        return;
    }
 
    show("You", question);
    messages.push({ role: "user", content: question });
    box.value = "";

    try {
        const response = await fetch(API, {
            method: "POST",
            headers: {
                Authorization: "Bearer " + KEY,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ model, messages })
        });

        if (!response.ok) {
            throw new Error(`Request failed: ${response.status}`);
        }

        const data = await response.json();
        const answer = data.choices?.[0]?.message?.content;

        if (!answer) {
            throw new Error("The response did not contain an answer.");
        }

        messages.push({ role: "assistant", content: answer });
        show("Tutor", answer);
    } catch (error) {
        show("Error", error.message);
    }
});

// 5. Week 9: on Convert, call the function named convert
// const form = document.querySelector("#convert"); // a second way
const form = document.getElementById("convert"); // find the form by its id
form.addEventListener("submit", convert);
// 6. Turn degrees Celsius into degrees Fahrenheit
function convert(event) {
    event.preventDefault(); // stay on this page
    const celsius = document.getElementById("celsius").value; // a string
    const fahrenheit = celsius * 9 / 5 + 32; // math gives a number
    const message = `${celsius} degrees C is ${fahrenheit} degrees F`;
    document.getElementById("result").textContent = message;
    console.log(fahrenheit === 77); // a boolean
}

// 7. Turn degrees Fahrenheit into degrees Celsius
const formf = document.getElementById("formf");
formf.addEventListener("submit", convertFahrenheit);
function convertFahrenheit(event) {
    event.preventDefault(); // stay on this page
    const fahrenheit = document.getElementById("fahrenheit").value; // a string
    const celsius = (fahrenheit - 32) * 5 / 9; // math gives a number
    const message = `${fahrenheit} degrees F is ${celsius} degrees C`;
    document.getElementById("resultf").textContent = message;
}

function show(who, text) {
    const p = document.createElement("p");
    p.textContent = who + ": " + text;
    document.querySelector("#chat").append(p);
}
