package Cx

import data.generic.dockerfile as dockerLib

CxPolicy[result] {
	resource := input.document[i].command[name][_]
	resource.Cmd == "run"

	count(resource.Value) == 1

	commands := resource.Value[j]
	command := dockerLib.getCommands(commands)[_]
	isAptGet(command)

	not avoidManualInput(command)

	result := {
		"documentId": input.document[i].id,
		"searchKey": sprintf("FROM={{%s}}.{{%s}}", [name, resource.Original]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": sprintf("{{%s}} should avoid manual input", [resource.Original]),
		"keyActualValue": sprintf("{{%s}} doesn't avoid manual input", [resource.Original]),
	}
}

CxPolicy[result] {
	resource := input.document[i].command[name][_]
	resource.Cmd == "run"

	count(resource.Value) > 1

	dockerLib.arrayContains(resource.Value, {"apt-get", "install"})

	not avoidManualInputInList(resource.Value)
	
    result := {
        "documentId": input.document[i].id,
        "searchKey": sprintf("FROM={{%s}}.{{%s}}", [name, resource.Original]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("{{%s}} should avoid manual input", [resource.Original]),
        "keyActualValue": sprintf("{{%s}} doesn't avoid manual input", [resource.Original]),
    }
}

isAptGet(command) {
	regex.match("apt-get (-(-)?[a-zA-Z]+ *)*install", command)
}

avoidManualInputInList(command) {
	flags := ["-y", "--yes", "--assume-yes", "-qy", "-q=2", "-qq"]
	
	contains(command[j], flags[x])
}

avoidManualInput(command) {
	regex.match("apt-get (-(-)?[a-zA-Z]+ *)*(-([A-Za-z])*y|--yes|-qq|-q=2|--assume-yes|(-q|--quiet)(.*(-q|--quiet)){1}) (-(-)?[a-zA-Z]+ *)*install", command)
}

avoidManualInput(command) {
	regex.match("apt-get (-(-)?[a-zA-Z]+ *)*install (-(-)?[a-zA-Z]+ *)*(-([A-Za-z])*y|--yes|-qq|-q=2|--assume-yes|(-q|--quiet)(.*(-q|--quiet)){1})", command)
}

avoidManualInput(command) {
	regex.match("apt-get (-(-)?[a-zA-Z]+ *)*install ([A-Za-z0-9\\W]+ *)*(-([A-Za-z])*y|--yes|-qq|-q=2|--assume-yes|(-q|--quiet)(.*(-q|--quiet)){1})", command)
}
