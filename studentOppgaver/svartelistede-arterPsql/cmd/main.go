package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"svarteliste/admin"
	"svarteliste/consts"
	"svarteliste/database"
	"svarteliste/frontend"
	"svarteliste/userform"

	//	_ "github.com/go-sql-driver/mysql"
	_ "github.com/lib/pq"
)
const (
  host     = "postgresql-flexible-server-rgstatic001.postgres.database.azure.com"
  port     = 5432
  user     = "ntnuadmin"
  password = ""
  dbname   = "svartelistede-arterpsql-db"
)



func main() {


    psqlInfo := fmt.Sprintf("host=%s port=%d user=%s "+
    "password=%s dbname=%s sslmode=require",
    host, port, user, os.Getenv("DBSECRET"), dbname)

    var err error
    database.DB, err = sql.Open("postgres", psqlInfo)
    if err != nil {
        panic(err)
    }
    defer database.DB.Close()

    err = database.DB.Ping()
    if err != nil {
        panic(err)
    }

    /**
    var err error
	// DATABASE
	// Create the database handle, confirm driver is present
	database.DB, err = sql.Open("mysql", "defUser:Kasseroller@tcp(10.212.170.74:3306)/svartelistedb?parseTime=true")
	if err != nil {
		log.Fatal(err)
	}
	defer database.DB.Close()
    */


    // Check status for database
	database.DatabaseStatus()
    

	//Admin css and js handlers
	http.Handle("/static/adminjs/", http.StripPrefix("/static/adminjs/", http.FileServer(http.Dir("./frontend/admin/javascript"))))
	http.Handle("/static/admincss/", http.StripPrefix("/static/admincss/", http.FileServer(http.Dir("./frontend/admin/css"))))
	//Userform css and js handlers
	http.Handle("/static/userformjs/", http.StripPrefix("/static/userformjs/", http.FileServer(http.Dir("./frontend/userform/javascript"))))
	http.Handle("/static/userformcss/", http.StripPrefix("/static/userformcss/", http.FileServer(http.Dir("./frontend/userform/css"))))
	//Image handlers
	http.Handle("/static/images/", http.StripPrefix("/static/images/", http.FileServer(http.Dir("./frontend/admin/images"))))
	http.Handle("/static/mapicons/", http.StripPrefix("/static/mapicons/", http.FileServer(http.Dir("./frontend/admin/mapicons"))))

	//Website handlers
	http.HandleFunc("/userform", frontend.UserformHandler)
	http.HandleFunc("/newuserform", frontend.NewUserformHandler)
	http.HandleFunc("/dashboard", frontend.AdminDashboardHandler)
	http.HandleFunc("/henvendelser/", frontend.AdminInquiryHandler)
	http.HandleFunc("/kart/", frontend.AdminMapHandler)
	http.HandleFunc("/offentligkart", frontend.AdminPublicMapHandler)
	http.HandleFunc("/login", frontend.AdminLoginHandler)
	http.HandleFunc("/signup", frontend.AdminSignupHandler)

	//Change status of inquiry
	http.HandleFunc("/confirminquiry", admin.ConfirmInquiry)
	http.HandleFunc("/processinquiry", admin.ProcessInquiry)
	http.HandleFunc("/deleteinquiry", admin.DeleteInquiry)
	http.HandleFunc("/combatedinquiry", admin.CombatedInquiry)
	http.HandleFunc("/recoverinquiry", admin.RecoverInquiry)

	//Manage inquiries
	http.HandleFunc("/runlogin/", admin.LoginHandler)
	http.HandleFunc("/sendplant", userform.RecieveInquiry)
	http.HandleFunc("/editinquiry", admin.EditInquiry)
	http.HandleFunc("/addcomment", admin.AddComment)
	http.HandleFunc("/addtolist", admin.AddToList)
	http.HandleFunc("/removefromlist", admin.RemoveFromList)
	http.HandleFunc("/setpublic", admin.SetPublic)
	http.HandleFunc("/setprivate", admin.SetPrivate)

	//TEST REQUEST
	http.HandleFunc("/makeinquiry", admin.MakeInquiry)

	// Extract PORT environment variable (Heroku compatible)
	port := os.Getenv("PORT")
	// Override with default port if not provided
	if port == "" {
		log.Println("$PORT has not been set. Default: 8080")
		port = consts.PORT
	}

	// Start HTTP server
	log.Println("Running on port", port)
	//HTTP (used during testing)
	err = http.ListenAndServe("0.0.0.0:"+port, nil)
	//HTTPS (used for normal operation, it needs to be https to share location on server)
	//err = http.ListenAndServeTLS(":"+port, "./cmd/localhost.crt", "./cmd/localhost.key", nil)
	if err != nil {
		log.Fatal(err.Error())
	}
}
