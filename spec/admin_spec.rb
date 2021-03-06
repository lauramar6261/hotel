require_relative 'spec_helper'
# REFACTOR IDEAS:
# replace before with let inside of it, use a nested describe that way I only have to create a single let variable
#

# runs from project directory
xdescribe "#Admin - initializer" do
  before do
    @admin = Admin.new
  end
  it "is an instance of Admin" do
    dispatcher = Admin.new
    expect(dispatcher).must_be_kind_of Admin
  end

  it "accurately loads reservation information into reservations array" do
    first_reservation = @admin.reservations.first
    last_reservation = @admin.reservations.last

    expect(first_reservation.start_time).must_equal Time.parse("2018-08-08 00:00:00 -0700")
    expect(first_reservation.end_time).must_equal Time.parse("2018-08-09 00:00:00 -0700")
    expect(first_reservation.nights).must_equal 1
    expect(first_reservation.cost).must_equal 200

    expect(last_reservation.start_time).must_equal Time.parse("2018-08-07 00:00:00 -0700")
    expect(last_reservation.end_time).must_equal Time.parse("2018-08-09 00:00:00 -0700")
    expect(last_reservation.nights).must_equal 2
    expect(last_reservation.cost).must_equal 400
  end

  it "accurately create_rooms" do
    first_room = @admin.rooms.first
    last_room = @admin.rooms.last
    expect(first_room.number).must_equal 1
    expect(last_room.number).must_equal 20
  end
end

xdescribe "#reservation information" do
  before do
    @admin = Admin.new
  end
  it "return the reservations that have a specific date, not including the last day" do
    #arrange
    # reservations are from test file
    # 2,2018-08-07,2018-08-09
    # 1,2018-08-08,2018-08-09

    date = "2018-08-08 00:00:00 -0700"
    reservations = @admin.find_reservations(date)

    expect(reservations).must_be_kind_of Array
    expect(reservations.length).must_equal 2
  end

  it "return the cost of a reservation" do
    #arrange
    reservation = @admin.reservations.first
    reservation_cost = @admin.find_cost(reservation)

    expect(reservation_cost).must_be_kind_of Integer
    expect(reservation_cost).must_equal 200
  end

end

xdescribe "#rooms information and reservation" do
  before do
    @admin = Admin.new
  end
  it "view all of the rooms" do

    rooms = @admin.view_all_rooms
    expect(rooms).must_be_kind_of Array
  end

  # REFACTOR idea:
  # before and after count of rooms from driver
  ## FUTURE WORK:  needs a test for this case
  #   reservation is 1 - 2
  #   and another one is 1 - 3, should include 2 rooms
  # needs a test with arrange to have block rooms and to check result

  ## FUTURE WORK: needs a test that reservation was made # checked in binding.pry, but needs the test
  it "can make a reservation" do
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    @admin.reserve_room(start_date, end_date)

    # reserve room removes last day because it is not counted as a paying night for my reservation class
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    start_date = Time.parse(start_date)
    end_date = Time.parse(end_date)
    end_date = end_date - 1
    range = [(start_date..end_date)]
    expect(@admin.rooms.first.ranges). must_equal range
  end

  it "no rooms available for 20 reservations" do
    start_date = Time.parse("2018-08-07 00:00:00 -0700")
    end_date = Time.parse("2018-08-09 00:00:00 -0700")
    expect {
    20.times do
      @admin.make_reservation(start_date, end_date)
    end
    }.must_raise StandardError
  end

  it "view vacant rooms" do
    # for reserve_room
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    @admin.reserve_room(start_date, end_date)
    # for range and testing view vacant_rooms
    s_date = Time.parse("2018-08-07 00:00:00 -0700")
    # one day less because the last night is not payed and view_vacant_rooms takes care of that
    e_date = Time.parse("2018-08-08 00:00:00 -0700")
    e_date = e_date - 1
    vacant_rooms_result = @admin.view_vacant_rooms(s_date, e_date)
    expect(vacant_rooms_result.length).must_equal 19
    # do I delete rooms from rooms? check for that
  end
end

xdescribe "#range tests" do
  before do
    @admin = Admin.new
  end

  it "does not count the last day" do
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    start_date = Time.parse(start_date)
    end_date = Time.parse(end_date)
    test_date = Time.parse("2018-08-09 00:00:00 -0700") # last day

    result = @admin.create_hotel_range(start_date, end_date)
    expect(result.include?(test_date)).must_equal false
  end

  it "it creates an array of dates" do
    start_date = Time.parse("2018-08-07 00:00:00 -0700")
    end_date = Time.parse("2018-08-10 00:00:00 -0700")
    result = @admin.create_array_of_dates(start_date, end_date)
    expect(result.length).must_equal 3
  end
end

describe "#blocks" do
  before do
    @admin = Admin.new
  end

  it "create a block of rooms" do
    skip
    # reserve a normal room
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    @admin.reserve_room(start_date, end_date)

    # reserve a block room
    data = {}
    data[:block_id] = 1
    data[:start_date] = start_date
    data[:end_date] = end_date
    data[:rooms] = 4
    data[:discounted_rate] = 100
    @admin.create_block_rooms(data)
    (0..3).each do |i|
      expect(@admin.rooms[i].blocks).wont_be_empty
    end
  end

  it "raises an Standard error for invalid rooms for block" do
    skip
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    @admin.reserve_room(start_date, end_date)
    # for range and testing view vacant_rooms
    # one day less because the last night is not payed and view_vacant_rooms takes care of that

    data = {}
    data[:block_id] = 1
    data[:start_date] = start_date
    data[:end_date] = end_date
    data[:rooms] = 6
    data[:discounted_rate] = 100
    expect{
      @admin.create_block_rooms(data)
    }.must_raise StandardError
  end

  it "updates status of room block" do
    skip
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    @admin.reserve_room(start_date, end_date)
    # for range and testing view vacant_rooms
    # one day less because the last night is not payed and view_vacant_rooms takes care of that

    data = {}
    data[:block_id] = 1
    data[:start_date] = start_date
    data[:end_date] = end_date
    data[:rooms] = 4
    data[:discounted_rate] = 100
    @admin.create_block_rooms(data)
    info = {}

    start_date = Time.parse("2018-08-07 00:00:00 -0700")
    end_date = Time.parse("2018-08-09 00:00:00 -0700")
    e_date = end_date - 1
    range = (start_date .. e_date)
    info = {}
    info[:room_num] = 2
    info[:range] = range
    @admin.reserve_room_in_block(info)
    room = @admin.rooms.select {|room| room.number == 2}.first
    blocks = room.blocks
    target_block = blocks.select {|block| block[:range] == range}[0]
    expect(target_block[:status]).must_equal "booked"
  end

  it "find a block" do
    skip
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    data = {}
    data[:block_id] = 1
    data[:start_date] = start_date
    data[:end_date] = end_date
    data[:rooms] = 4
    data[:discounted_rate] = 100
    @admin.create_block_rooms(data)
    info = {}

    start_date = Time.parse("2018-08-07 00:00:00 -0700")
    end_date = Time.parse("2018-08-09 00:00:00 -0700")
    e_date = end_date - 1
    range = (start_date .. e_date)
    info = {}
    info[:room_num] = 2
    info[:range] = range
    @admin.reserve_room_in_block(info)
    rooms = @admin.find_block(range)
    expect(rooms.length).must_equal 4
  end

  it "view_vacant_rooms_in_block" do
    skip
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    data = {}
    data[:block_id] = 1
    data[:start_date] = start_date
    data[:end_date] = end_date
    data[:rooms] = 4
    data[:discounted_rate] = 100
    @admin.create_block_rooms(data)
    info = {}

    start_date = Time.parse("2018-08-07 00:00:00 -0700")
    end_date = Time.parse("2018-08-09 00:00:00 -0700")
    e_date = end_date - 1
    range = (start_date .. e_date)
    info = {}
    info[:room_num] = 2
    info[:range] = range
    @admin.reserve_room_in_block(info)
    rooms = @admin.view_vacant_rooms_in_block(range)
    expect(rooms.length).must_equal 3
  end

  it "an outsider of a party can't reserve a room in a block" do
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    data = {}
    data[:block_id] = 1
    data[:start_date] = start_date
    data[:end_date] = end_date
    data[:rooms] = 4
    data[:discounted_rate] = 100
    # it creates 4 room blocks
    @admin.create_block_rooms(data)

    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    @admin.reserve_room(start_date, end_date)
    # to test the expected result
    start_date = "2018-08-07 00:00:00 -0700"
    end_date = "2018-08-09 00:00:00 -0700"
    start_date = Time.parse(start_date)
    end_date = Time.parse(end_date)
    range = [(start_date...end_date)]
    # 4 is 5 room - index starts at 0
    expect(@admin.rooms[4].ranges).wont_be_empty
  end
end
