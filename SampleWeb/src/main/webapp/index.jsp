<html>
<head>
	<title>API Example</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
	<script type="text/javascript">

		var accessToken = "b32250b5d97f45118abbf80529249863";
		var baseUrl = "https://api.api.ai/v1/";

		$(document).ready(function() {
			$("#input").keypress(function(event) {
				if (event.which == 13) {
					event.preventDefault();
					send();
				}
			});
			$("#rec").click(function(event) {
				switchRecognition();
			});
		});

		var recognition;

		function startRecognition() {
			recognition = new webkitSpeechRecognition();
			recognition.onstart = function(event) {
				updateRec();
			};
			recognition.onresult = function(event) {
				var text = "";
			    for (var i = event.resultIndex; i < event.results.length; ++i) {
			    	text += event.results[i][0].transcript;
			    }
			    setInput(text);
				stopRecognition();
			};
			recognition.onend = function() {
				stopRecognition();
			};
			recognition.lang = "en-US";
			recognition.start();
		}
	
		function stopRecognition() {
			if (recognition) {
				recognition.stop();
				recognition = null;
			}
			updateRec();
		}

		function switchRecognition() {
			if (recognition) {
				stopRecognition();
			} else {
				startRecognition();
			}
		}

		function setInput(text) {
			$("#input").val(text);
			send();
		}

		function updateRec() {
			$("#rec").text(recognition ? "Stop" : "Speak");
		}

		function send() {
			var text = $("#input").val();
			setResponse("<div class='container darker' style='width:70%; margin-left: auto'>" +
					 " <p>"+text+"</p>" +
					 " <span class='time-right'>11:01</span>" +
				" </div>");
			$("#input").val("");
			$.ajax({
				type: "POST",
				url: baseUrl + "query?v=20150910",
				contentType: "application/json; charset=utf-8",
				dataType: "json",
				headers: {
					"Authorization": "Bearer " + accessToken
				},
				data: JSON.stringify({ query: text, lang: "en", sessionId: "somerandomthing" }),

				success: function(data) {
					//setResponse(JSON.stringify(data, undefined, 2));
					//setResponse("Bot: " + data.result.fulfillment.speech);
					
					setResponse("<div class='container' style='width:70%'>" +
					 " <p>"+JSON.stringify(data, undefined, 2)+"</p>" +
					 " <span class='time-right'>11:01</span>" +
				" </div>");
				},
				error: function() {
					setResponse("Internal Server Error");
				}
			});
		}

		function setResponse(val) {
			$("#response").append(val);
		}

	</script>
	<style type="text/css">
		body { width: 500px; margin: 0 auto; text-align: center; margin-top: 20px; 
		max-width: 800px;
		padding: 0 20px;}
		input { width: 400px; }
		button { width: 50px; }
		textarea { width: 100%; }

		.container {
			border: 2px solid #dedede;
			background-color: #f1f1f1;
			border-radius: 5px;
			padding: 10px;
			margin: 10px 0;
		}
		.chatbox {
			border: 2px solid #dedede;
			background-color: white;
			border-radius: 5px;
			padding: 10px;
			margin: 10px 0;
		}

		.darker {
			border-color: #ccc;
			background-color: #ddd;
		}

		.container::after {
			content: "";
			clear: both;
			display: table;
		}

		.container img {
			float: left;
			max-width: 60px;
			width: 100%;
			margin-right: 20px;
			border-radius: 50%;
		}

		.container img.right {
			float: right;
			margin-left: 20px;
			margin-right:0;
		}

		.time-right {
			float: right;
			color: #aaa;
		}

		.time-left {
			float: left;
			color: #999;
		}
	</style>
</head>
<body>
	<div class="chatbox" style="width:500px">
		<div id="response"></div>
	</div>
	<div>
	<br/><br/>
		<input id="input" type="text"> 
		<button id="rec" hidden="hidden">Speak</button>
		<button id="enter">Enter</button>
	</div>
</body>
</html>