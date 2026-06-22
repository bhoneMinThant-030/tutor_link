import '../models/booking.dart';
import '../models/tutor.dart';

/// In-memory sample data so the UI looks realistic in Part 2.
/// Part 3 replaces these lists with live Firestore queries.

final List<Tutor> kDummyTutors = [
  const Tutor(
    id: 't1',
    name: 'Jun Meng',
    course: 'Computer Engineering',
    hourlyRate: 15,
    rating: 4.9,
    subjects: ['COMT', 'MATHS'],
    about:
        'Year 3 Computer Engineering student. Excellent distinction in '
        'Engineering Maths. I tutor juniors because I remember how confusing '
        'these modules felt in Year 1.',
    availability: 'Available most weeknights from 7pm and all day Saturday.',
    //imageUrl:'https://media.istockphoto.com/id/1444077739/photo/college-study-and-education-student-man-portrait-with-back-to-school-backpack-and-portfolio.jpg?s=612x612&w=0&k=20&c=PAQmqKzYd3OiKhlfrT1DVMQNkGu-drX4rtJ5p6y7D8c='
  ),
  const Tutor(
    id: 't2',
    name: 'Felicia',
    course: 'Information Technology',
    hourlyRate: 15,
    rating: 4.5,
    subjects: ['COMT', 'UIXD'],
    about: 'Passionate about UI/UX and front-end development.',
    availability: 'Weekday afternoons and Sunday mornings.',
  ),
  const Tutor(
    id: 't3',
    name: 'Jariya',
    course: 'Applied AI',
    hourlyRate: 15,
    rating: 4.9,
    subjects: ['COMT', 'DAVA'],
    about: 'Data analytics enthusiast who loves making numbers make sense.',
    availability: 'Evenings on weekdays.',
  ),
];

const List<Booking> kDummyBookings = [
  Booking(
    id: 'b1',
    tutorName: 'PAI',
    course: 'Computational Thinking',
    subject: 'Computational Thinking',
    dateLabel: 'Jun 22, 2026',
    timeLabel: '2:00PM-4:00PM',
    location: 'Library, Study Hub 3',
    status: BookingStatus.confirmed,
    isUpcoming: true,
  ),
  Booking(
    id: 'b2',
    tutorName: 'DAVID',
    course: 'Data Visualization',
    subject: 'Data Visualization',
    dateLabel: 'Jun 24, 2026',
    timeLabel: '7:00PM-9:00PM',
    location: 'Zoom Meeting',
    status: BookingStatus.confirmed,
    isUpcoming: true,
  ),
  Booking(
    id: 'b3',
    tutorName: 'Eric',
    course: 'UIXD',
    subject: 'UIXD',
    dateLabel: 'Jul 2, 2026',
    timeLabel: '4:00PM-6:00PM',
    location: 'Pixel garden 1',
    status: BookingStatus.pending,
    isUpcoming: true,
  ),
  Booking(
    id: 'b4',
    tutorName: 'Felicia',
    course: 'Information Technology',
    subject: 'UIXD',
    dateLabel: 'May 30, 2026',
    timeLabel: '3:00PM-5:00PM',
    location: 'Library, Study Hub 1',
    status: BookingStatus.confirmed,
    isUpcoming: false,
  ),
];
