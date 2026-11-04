function calculate(a, op, b) {
    if (op === '+') {
        return a + b;
    } else if (op === '-') {
        return a - b;
    } else if (op === '*') {
        return a * b;
    } else {
        return a / b;  
    }
} 

function showAnswer() {
    const a = Number(document.getElementById("a").value);
    const b = Number(document.getElementById("b").value);
    const op = document.getElementById("op").value;
    const answer = calculate(a, op, b);
    document.getElementById("result").textContent = answer;
}

const button = document.getElementById("calc");
button.addEventListener("click", showAnswer);



function creditLabel(score) {
    if (score >= 800) {
        return "Exceptional";
    } else if (score >= 740) {
        return "Very Good";
    } else if (score >= 670) {
        return "Good";
    } else if (score >= 580) {
        return "Fair";
    } else {
        return "Poor";
    }
}

function showLabel() {
    const score = Number(document.getElementById("score").value);
    const label = creditLabel(score);
    document.getElementById("rating").textContent = label;
}

const checkButton = document.getElementById("check");
checkButton.addEventListener("click", showLabel);






const ranges = [
    { label: "Exceptional", min: 800 },
    { label: "Very Good", min: 740 },
    { label: "Good", min: 670 },
    { label: "Fair", min: 580 }
];


// 8. Find the empty list, then add one li for each range
const list = document.querySelector("#ranges");
ranges.forEach(function (r) {
    const li = document.createElement("li"); // create
    li.textContent = `${r.label}: ${r.min} and above`; // fill
    list.appendChild(li); // attach
});

const factors = [
    { label: "Payment history", percentage: 35 },
    { label: "Amounts owed", percentage: 30 },
    { label: "Length of credit history", percentage: 15 },
    { label: "New credit", percentage: 10 },
    { label: "Credit mix", percentage: 10 }
];

const factorList = document.querySelector("#factors");
factors.forEach(function (f) {
    const li = document.createElement("li"); // create
    li.textContent = `${f.label}: ${f.percentage}%`;
    factorList.appendChild(li); // attach
});



//11. New Today: the label changes as you type, before any click
const scoreBox = document.getElementById("score");
scoreBox.addEventListener("input", function (event) {
    const score = Number(event.target.value); // the text as a number
    document.getElementById("rating").textContent = `${score} is ${creditLabel(score)}`;
});

//12. New Today: one click switches the page's colors on and off
const themeButton = document.getElementById("theme");
themeButton.addEventListener("click", function () {
    document.body.classList.toggle("bg-dark"); // dark background
    document.body.classList.toggle("text-white"); // white text
});