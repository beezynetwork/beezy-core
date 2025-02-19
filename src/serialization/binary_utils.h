// Copyright (c) 2014-2017 The The Louisdor Project
// Copyright (c) 2012-2013 The Cryptonote developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include <sstream>
#include "binary_archive.h"

#include <boost/serialization/serialization.hpp>
#include <boost/serialization/version.hpp>
#if BOOST_VERSION / 100000 == 1 && BOOST_VERSION / 100 % 1000 == 74
#include <boost/serialization/library_version_type.hpp>
#endif
#include <boost/serialization/list.hpp>

namespace serialization {

template <class T>
bool parse_binary(const std::string &blob, T &v)
{
  std::istringstream istr(blob);
  binary_archive<false> iar(istr);
  return ::serialization::serialize(iar, v);
}

template<class T>
bool dump_binary(T& v, std::string& blob)
{
  std::stringstream ostr;
  binary_archive<true> oar(ostr);
  bool success = ::serialization::serialize(oar, v);
  blob = ostr.str();
  return success && ostr.good();
};

} // namespace serialization
