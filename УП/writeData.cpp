#include <bits/stdc++.h>
#include "flights.h"

void writeData() {
    ifstream foutb("output.bf", ios::binary);
    ofstream fout("output.txt");
    vector <Item> answer;
    while(!foutb.eof()) {
        Item c;
        foutb.read(reinterpret_cast<char*>(&c), sizeof c);
        answer.push_back(c);
    }
    answer.pop_back();
    for(auto x: answer) fout << x << endl;
}
