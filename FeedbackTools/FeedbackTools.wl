BeginPackage["FeedbackTools`"]

SendFeedback::usage = "SendFeedback[] sends customer feedback";
CrashDumpFiles::usage = "CrashDumpFiles[] gives the list of crashdump information files";

Begin["`Private`"]

$FeedbackInformation := "Kernel:\n\tSystem id - " <> SystemInformation["Kernel", "SystemID"] <>
"\n\tRelease id - " <> SystemInformation["Kernel", "ReleaseID"] <>
"\n\tCreation date - " <> TextString[SystemInformation["Kernel", "CreationDate"]] <>
"\nFrontEnd:\n\tOperating system - " <> SystemInformation["FrontEnd", "OperatingSystem"] <>
"\n\tRelease id - " <> SystemInformation["FrontEnd", "ReleaseID"] <>
"\n\tCreation date - " <> TextString[SystemInformation["FrontEnd", "CreationDate"]];

If[ $SystemID === "MacOSX-x86-64",
  $CrashDumpsDirectory = FileNameJoin[{$HomeDirectory,"Library","Logs","DiagnosticReports"}];
]

If[ $SystemID === "Windows-x86-64",
  $CrashDumpsDirectory = FileNameJoin[{$HomeDirectory, "AppData", "Local", "CrashDumps"}];
]

$CrashDumpPattern = Switch[
  $SystemID,
  "Windows-x86-64", "Mathematica*.dmp" | "WolframKernel*.dmp",
  "MacOSX-x86-64", "Mathematica*.crash" | "WolframKernel*.crash",
  _ , ""
]

CrashDumpFiles[] := CrashDumpFiles[ $CrashDumpsDirectory ];

CrashDumpFiles[ directory_ ] := FileNames[ $CrashDumpPattern, directory ];

SendFeedback[ assoc_Association ] := Module[{attached={}},
  If[ StringQ[assoc["Notebook"]] && FileType[assoc["Notebook"]]===File, AppendTo[attached,assoc["Notebook"]] ];
  If[ StringQ[assoc["CrashDump"]] && FileType[assoc["CrashDump"]]===File, AppendTo[attached,assoc["CrashDump"]] ];
  SendMail[
 <|
  "To" -> assoc["Recipient"],
  "Subject" -> "Crash report",
  "TextBody" -> assoc["Message"] <> "\n\n\n" <> $FeedbackInformation,
  "AttachedFiles" -> attached
  |>
 ]
]

End[]

EndPackage[]
