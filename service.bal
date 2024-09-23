import ballerina/http;
import ballerina/time;

 public type Course record {|
    string courseCode;
    string courseName;
    int nqfLevel;
|};




public type Programme record {|
    readonly string programme_code;
    int nqfLevel;
    string faculty;
    string department;
    string qualification_title;
    time:Date registrationDate;
    Course[] courses;
|};

public final table<Programme> key(programme_code) programmes = table key(programme_code) [
    {
        programme_code: "CS100",
        nqfLevel: 6, 
        faculty: "Computing and Informatics",
        department: "Computer Science",
        qualification_title: "Bachelor of Computer Science",
        registrationDate: {year: 2023, month: 7, day: 1},
        courses: []
    },
    {
        programme_code: "EN101",
        nqfLevel: 7,
        faculty: "Engineering",
        department: "Civil Engineering",
        qualification_title: "Bachelor of Civil Engineering",
        registrationDate: {year: 2023, month: 3, day: 10},
        courses: []
    },
    {
        programme_code: "EN102",
        nqfLevel: 7,
        faculty: "Engineering",
        department: "Mechanical Engineering",
        qualification_title: "Bachelor of Mechanical Engineering",
        registrationDate: {year: 2016, month: 8, day: 24},
        courses: []
    }
];

service /programmeService on new http:Listener(8080) {

    // Add a new programme
    resource function post .(@http:Payload Programme payload) returns http:Created|http:Conflict {
        if programmes.hasKey(payload.programme_code) {
            return http:CONFLICT;
        }
        programmes.add(payload);
        return http:CREATED;
    }

    // Get a list of all programmes
    resource function get .() returns Programme[] {
        return programmes.toArray();
    }

    // Update an existing programme
    resource function put programmes/[string programme_code](@http:Payload Programme payload) returns http:NotFound & readonly|http:Ok & readonly {
        if !programmes.hasKey(programme_code) {
            return http:NOT_FOUND;
        }
        programmes.put(payload);
        return http:OK;
    }

    // Get a specific programme by code
    resource function get [string programme_code]() returns Programme|http:NotFound {
        if programmes.hasKey(programme_code) {
            return programmes.get(programme_code);
        }
        return http:NOT_FOUND;
    }

    // Delete a programme
    resource function delete programmes/[string programme_code]() returns http:NoContent|http:NotFound {
        if programmes.hasKey(programme_code) {
            _ = programmes.remove(programme_code);
            return http:NO_CONTENT;
        }
        return http:NOT_FOUND;
    }
                //
    // Get programmes due for review (older than 5 years)
    resource function get programmes/due_for_review() returns Programme[]|error {
        time:Utc currentTime = time:utcNow();
        Programme[] dueProgrammes = [];
        foreach Programme p in programmes {
            time:Utc registrationUtc = check time:utcFromCivil({
                year: p.registrationDate.year,
                month: p.registrationDate.month,
                day: p.registrationDate.day,
                hour: 0,
                minute: 0,
                second: 0
            });
            time:Seconds timeDiff = time:utcDiffSeconds(currentTime, registrationUtc);
            decimal yearsDiff = timeDiff / (365.25d * 24 * 60 * 60);  // Time difference in years
            if yearsDiff >= 5d {  // Convert 5 to a decimal
                dueProgrammes.push(p);
            }
        }
        return dueProgrammes;
    }
    // Retrieve all programmes by faculty
    resource function get programmes/by_faculty/[string faculty]() returns Programme[] {
        Programme[] filteredProgrammes = programmes.toArray().filter(function(Programme p) returns boolean {
            return p.faculty == faculty;
        });
        return filteredProgrammes;
    }
}
