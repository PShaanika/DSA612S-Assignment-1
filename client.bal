import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client clientEP = check new("http://localhost:8080/programmeService");

    while true {
        // Display the user menu
        io:println("\n=== Programme Management Options ===");
        io:println("1. Add a new programme");
        io:println("2. Retrieve a list of all programmes");
        io:println("3. Update an existing programme's information");
        io:println("4. Retrieve the details of a specific programme by code");
        io:println("5. Delete a programme's record by programme code");
        io:println("6. Retrieve all programmes that are due for review");
        io:println("7. Retrieve all programmes that belong to the same faculty");
        io:println("8. Exit");

        // Get the user's choice as a string
        io:print("\nEnter your choice (1-8): ");
        string choice = check io:readln();

        match choice {
            "1" => {
                // Add a new programme
                addProgramme(clientEP);
            }
            "2" => {
                // Retrieve a list of all programmes
                error? allProgrammes = getAllProgrammes(clientEP);
            }
            "3" => {
                // Update an existing programme
                updateProgramme(clientEP);
            }
            "4" => {
                // Retrieve the details of a specific programme by code
                error? programmeByCode = getProgrammeByCode(clientEP);
            }
            "5" => {
                // Delete a programme
                deleteProgramme(clientEP);
            }
            "6" => {
                // Retrieve all programmes due for review
                error? programmesDueForReview = getProgrammesDueForReview(clientEP);
            }
            "7" => {
                // Retrieve all programmes that belong to the same faculty
                error? programmesByFaculty = getProgrammesByFaculty(clientEP);
            }
            "8" => {
                io:println("Exiting the application...");
                break;
            }
            _ => {
                io:println("Invalid choice! Please select a valid option.");
            }
        }
    }
}

function addProgramme(http:Client clientEP) {
    json newProgramme = {
        programme_code: "IT104",
        nqfLevel: 6,
        faculty: "Information Technology",
        department: "Network Engineering",
        qualification_title: "Bachelor of Network Engineering",
        registrationDate: {year: 2021, month: 5, day: 12},
        courses: []
    };

    http:Response|error addResponse = clientEP->post("/", newProgramme);
    if addResponse is http:Response && addResponse.statusCode == 201 {
        io:println("Programme added successfully.");
    } else {
        io:println("Failed to add programme.");
    }
}

function getAllProgrammes(http:Client clientEP) returns error? {
    http:Response|error getAllResponse = clientEP->get("/");
    if getAllResponse is http:Response {
        json payload = check getAllResponse.getJsonPayload();
        io:println("List of all programmes: ", payload);
    } else {
        io:println("Failed to retrieve programmes.");
    }
}

function updateProgramme(http:Client clientEP) {
    io:print("Enter the programme code to update: ");
    string programmeCode = check io:readln();

    json updatedProgramme = {
        programme_code: programmeCode,
        nqfLevel: 7,  // Example update
        faculty: "Computing and Informatics",
        department: "Data Science",
        qualification_title: "Bachelor of Data Science",
        registrationDate: {year: 2023, month: 1, day: 1},
        courses: []
    };

    http:Response|error updateResponse = clientEP->put("/programmes/" + programmeCode, updatedProgramme);
    if updateResponse is http:Response && updateResponse.statusCode == 200 {
        io:println("Programme updated successfully.");
    } else {
        io:println("Failed to update programme.");
    }
}

function getProgrammeByCode(http:Client clientEP) returns error? {
    io:print("Enter the programme code to retrieve: ");
    string programmeCode = check io:readln();

    http:Response|error getByCodeResponse = clientEP->get("/" + programmeCode);
    if getByCodeResponse is http:Response {
        json payload = check getByCodeResponse.getJsonPayload();
        io:println("Programme details: ", payload);
    } else {
        io:println("Failed to retrieve programme.");
    }
}

function deleteProgramme(http:Client clientEP) {
    io:print("Enter the programme code to delete: ");
    string programmeCode = check io:readln();

    http:Response|error deleteResponse = clientEP->delete("/programmes/" + programmeCode);
    if deleteResponse is http:Response && deleteResponse.statusCode == 204 {
        io:println("Programme deleted successfully.");
    } else {
        io:println("Failed to delete programme.");
    }
}

function getProgrammesDueForReview(http:Client clientEP) returns error? {
    http:Response|error getDueForReviewResponse = clientEP->get("/programmes/due_for_review");
    if getDueForReviewResponse is http:Response {
        json payload = check getDueForReviewResponse.getJsonPayload();
        io:println("Programmes due for review: ", payload);
    } else {
        io:println("Failed to retrieve due programmes.");
    }
}

function getProgrammesByFaculty(http:Client clientEP) returns error? {
    io:print("Enter the faculty name: ");
    string faculty = check io:readln();

    http:Response|error getByFacultyResponse = clientEP->get("/programmes/by_faculty/" + faculty);
    if getByFacultyResponse is http:Response {
        json payload = check getByFacultyResponse.getJsonPayload();
        io:println("Programmes in faculty: ", payload);
    } else {
        io:println("Failed to retrieve programmes.");
    }
}
