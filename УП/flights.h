#ifndef FLIGHTS_H_INCLUDED
#define FLIGHTS_H_INCLUDED

using namespace std;

void readData();
void processData();
void writeData();

struct Time {
    int h, m;
    Time(): h(0), m(0) {}
    Time(int h, int m): h(h), m(m) {}
    bool operator == (const Time &rhs) const {
        return h == rhs.h && m == rhs.m;
    }
    friend istream& operator >> (istream &in, Time &rhs) {
        char temp;
        in >> rhs.h >> temp >> rhs.m;
        return in;
    }
    friend ostream& operator << (ostream &out, Time &rhs) {
        if (rhs.h < 10) out << 0;
        out << rhs.h << '.';
        if (rhs.m < 10) out << 0;
        out << rhs.m;
        return out;
    }
    string toString() const {
        char s[6];
        sprintf(s, "%02d:%02d", h, m);
        return string(s);
    }

    int toMinutes() const {
        return h * 60 + m;
    }

    Time get(int s) const {
        Time ret;
        ret.h = s / 60;
        ret.m = s % 60;
        return ret;
    }

    Time operator - (const Time &rhs) const {
        int s = toMinutes() - rhs.toMinutes();
        if (s < 0) s += 24 * 60;
        return get(s);
    }
    bool operator < (const Time &rhs) const {
        return toMinutes() < rhs.toMinutes();
    }
};

struct Item {
    int id;
    char dest[200];
    Time dep, arr;
    int free;
    int duration() const {
        return (arr - dep).toMinutes();
    }
    friend istream& operator >> (istream& in, Item &rhs) {
        in >> rhs.id >> rhs.dest >> rhs.dep >> rhs.arr >> rhs.free;
        return in;
    }
    friend ostream& operator << (ostream& out, Item &rhs) {
        out << rhs.id << ' ' << rhs.dest << ' ' << rhs.dep << ' ' << rhs.arr << ' ' << rhs.free;
        return out;
    }
    bool operator < (const Item &rhs) const {
        return strcmp(dest, rhs.dest) == -1;
    }
};


#endif // FLIGHTS_H_INCLUDED
