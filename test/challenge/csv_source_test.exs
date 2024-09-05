defmodule Challenge.CSVSourceTest do
  use ExUnit.Case, async: true

  alias Challenge.CSVSource

  describe "stream_permits/1" do
    csv = [
      "locationid,Applicant,FacilityType,cnn,LocationDescription,Address,blocklot,block,lot,permit,Status,FoodItems,X,Y,Latitude,Longitude,Schedule,dayshours,NOISent,Approved,Received,PriorPermit,ExpirationDate,Location",
      "1723825,Natan's Catering,Truck,7727000,KANSAS ST: 16TH ST to 17TH ST (300 - 399),350 KANSAS ST,3958001D,3958,001D,23MFF-00006,APPROVED,Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks,6011363.148,2106748.619,37.76537066931712,-122.40390784821223,http://bsm.sfdpw.org/PermitsTracker/reports/report.aspx?title=schedule&report=rptSchedule&params=permit=23MFF-00006&ExportPDF=1&Filename=23MFF-00006_schedule.pdf,,,09/12/2023 12:00:00 AM,20230911,1,11/15/2024 12:00:00 AM,\"(37.76537066931712, -122.40390784821223)\""
    ]

    assert [permit] =
             csv
             |> CSVSource.stream_permits()
             |> Enum.to_list()

    assert %{
             "location_id" => "1723825",
             "permit_holder" => "Natan's Catering",
             "location_description" => "KANSAS ST: 16TH ST to 17TH ST (300 - 399)",
             "permit_number" => "23MFF-00006",
             "status" => "approved",
             "food_items" =>
               "Burgers: melts: hot dogs: burritos:sandwiches: fries: onion rings: drinks",
             "hours_of_operation" => ""
           } = permit
  end
end
