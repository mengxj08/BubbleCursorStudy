<?php
if (!empty($_POST)) {
    $taskNum= $_POST["taskNum"];
    setcookie("taskNum",$taskNum,time()+(3600*3));
    //echo "hello";
} else {
	$taskNum = $_COOKIE["taskNum"];
}
if (!isset($_COOKIE["user"])){
    $message = "Please use a participant ID";
    header("Location: index.php?message=".$message);
    exit;
}
$user = $_COOKIE["user"];

if (!isset($_COOKIE["block"])){
    $message = "No block in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$block = $_COOKIE["block"];

if (!isset($_COOKIE["max_blocks"])){
    $message = "No max_blocks in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$max_blocks = $_COOKIE["max_blocks"];

if (!isset($_COOKIE["trial"])){
    $message = "No trial in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$trial = $_COOKIE["trial"];

if (!isset($_COOKIE["max_trials"])){
    $message = "No max_trials in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$max_trials = $_COOKIE["max_trials"];

if (!isset($_COOKIE["condition"])){
    $message = "No condition in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$condition = $_COOKIE["condition"];

if (!isset($_COOKIE["max_conditions"])){
    $message = "No max_conditions in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$max_conditions = $_COOKIE["max_conditions"];

if (!isset($_COOKIE["CurrentTrial"])){
    $message = "No CurrentTrial in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$CurrentTrial = $_COOKIE["CurrentTrial"];

if (!isset($_COOKIE["TrialsperBlock"])){
    $message = "No TrialsperBlock in the cookie";
    header("Location: index.php?message=".$message);
    exit;
}
$TrialsperBlock = $_COOKIE["TrialsperBlock"];
/*
Retrieve the data name 
*/

$json = json_decode(file_get_contents("design/Arrangement.json"), true);
$Autojson = $json["children"][$taskNum]["children"][$block]["children"][$condition]["name"];
$pieces = explode(",", $Autojson);
$ID1 = explode("(", $pieces[0])[1];
$ID2 = $pieces[1];
$ID3 = $pieces[2];
$ID4 = explode(")", $pieces[3])[0];

session_start();
$session_name = "recordedData";
$session_subject = "subjectID";
$session_betweenIV = "betweenIV";

if(!isset($_SESSION[$session_name])) {
    $_SESSION[$session_name] = $json["children"][$taskNum]["children"];
}
if(!isset($_SESSION[$session_subject])) {
    $_SESSION[$session_subject] = $user;
}
if(!isset($_SESSION[$session_betweenIV])) {
    $_SESSION[$session_betweenIV] = $json["children"][$taskNum]["name"];
}
?>

<html>
<head>
<title>Experiment Run Template</title>

<link rel="stylesheet" href="css/general.css" />
<script type="text/javaScript" src="js/count_time.js"></script>
<script type="text/javascript" src="js/processing.min.js"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
<script>
    var bound = false;

    function bindJavascript() {
        var pjs = Processing.getInstanceById('example_pde');
        if(pjs != null) {
          pjs.bindJavascript(this);
          bound = true; 
      	}
        if(!bound) setTimeout(bindJavascript, 250);
      }
    bindJavascript();

    var ID1 = "<?php echo trim($ID1) ?>";
    var ID2 = <?php echo trim($ID2) ?>;
    var ID3 = <?php echo trim($ID3) ?>;
    var ID4 = <?php echo trim($ID4) ?>;
	var taskTime;
	var numMisses;
    var passDataToJS = function (totaltime,totalmiss){
    	taskTime = totaltime;
    	numMisses = totalmiss;
    	//console.log(totaltime);
    }
	function change()
	{
		//var taskTime = Math.floor(secs/1000);
        if(taskTime!=null && numMisses!=null){
            stop_timer();
            jump("mask.php",taskTime,numMisses);
        }
		
	}
	function jump(next_page, totaltime,totalmiss)
	{
		location.href = next_page+"?taskTime="+totaltime+"&taskMiss="+totalmiss;
	}
	//monitor the space key press event, and stop the timer;
	// $(document).ready(function(){
	// 	$(window).keypress(function(e){
	// 		//alert(e.which);
	// 		//alert(e.keyboard);
	// 		if(e.which == 32)
	// 		{
	// 			stop_timer();
	// 			var taskTime = Math.floor(secs/1000);
	// 			//write the target tuple to the log file
			
	// 			//write the spent time on this page	to the log file
				 
	// 			//jump to the mask page	  
	// 			jump("mask.php", taskTime);
	// 		}
	// 	});
	// });
</script>
</head>
<body> 
<div id="Header">
    <div id="InstructionAreaBox">
        <div id="InstructionArea">
		<left>
		<table>
			<b>Participant ID: </b> 
			  	<?php echo $user ?>
				&nbsp; Trial: <?php echo $CurrentTrial ?>/<?php echo $TrialsperBlock ?>
				&nbsp;
				&nbsp; Block: <?php echo ($block + 1) ?>/<?php echo $max_blocks ?>
				&nbsp;
			<b>Timer. <script language="JavaScript">run()</script> </b> 
			<hr />	
			<p><?php echo $Autojson ?></p>
			<div id="InstructionText">
				<p>Instruction here</p>
            </div>
		</table>
        </div>
    </div>
    <div id="InstructionButtonArea">
    	<center>
    	<button class="button1" onclick="change()" style="width: 120; height: 65; margin-top: 65px; font-size: 18px"><text class="black">Next task</text></button>
    	</center>
    </div>
</div>
<canvas id="example_pde" data-processing-sources="example_pde/example_pde.pde"></canvas>
</body>
</html>

